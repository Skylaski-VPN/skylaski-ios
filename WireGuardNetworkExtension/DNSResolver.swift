// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Network
import Foundation

enum DNSResolver {}

extension DNSResolver {

    /// Concurrent queue used for DNS resolutions
    private static let resolverQueue = DispatchQueue(label: "DNSResolverQueue", qos: .default, attributes: .concurrent)

    static func resolveSync(endpoints: [Endpoint?]) -> [Result<Endpoint, DNSResolutionError>?] {
        let isAllEndpointsAlreadyResolved = endpoints.allSatisfy { maybeEndpoint -> Bool in
            return maybeEndpoint?.hasHostAsIPAddress() ?? true
        }

        if isAllEndpointsAlreadyResolved {
            return endpoints.map { endpoint in
                return endpoint.map { .success($0) }
            }
        }

        return endpoints.concurrentMap(queue: resolverQueue) { endpoint -> Result<Endpoint, DNSResolutionError>? in
            guard let endpoint = endpoint else { return nil }

            if endpoint.hasHostAsIPAddress() {
                return .success(endpoint)
            } else {
                return Result { try DNSResolver.resolveSync(endpoint: endpoint) }
                    .mapError { error -> DNSResolutionError in
                        // swiftlint:disable:next force_cast
                        return error as! DNSResolutionError
                    }
            }
        }
    }

    private static func resolveSync(endpoint: Endpoint) throws -> Endpoint {
        guard case .name(let name, _) = endpoint.host else {
            return endpoint
        }

        var hints = addrinfo()
        hints.ai_flags = AI_ALL // We set this to ALL so that we get v4 addresses even on DNS64 networks
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_DGRAM
        hints.ai_protocol = IPPROTO_UDP

        var resultPointer: UnsafeMutablePointer<addrinfo>?
        defer {
            resultPointer.flatMap { freeaddrinfo($0) }
        }

        let errorCode = getaddrinfo(name, "\(endpoint.port)", &hints, &resultPointer)
        if errorCode != 0 {
            throw DNSResolutionError(errorCode: errorCode, address: name)
        }

        var ipv4Address: IPv4Address?
        var ipv6Address: IPv6Address?

        var next: UnsafeMutablePointer<addrinfo>? = resultPointer
        let iterator = AnyIterator { () -> addrinfo? in
            let result = next?.pointee
            next = result?.ai_next
            return result
        }

        for addrInfo in iterator {
            if let maybeIpv4Address = IPv4Address(addrInfo: addrInfo) {
                ipv4Address = maybeIpv4Address
                break // If we found an IPv4 address, we can stop
            } else if let maybeIpv6Address = IPv6Address(addrInfo: addrInfo) {
                ipv6Address = maybeIpv6Address
                continue // If we already have an IPv6 address, we can skip this one
            }
        }

        // We prefer an IPv4 address over an IPv6 address
        if let ipv4Address = ipv4Address {
            return Endpoint(host: .ipv4(ipv4Address), port: endpoint.port)
        } else if let ipv6Address = ipv6Address {
            return Endpoint(host: .ipv6(ipv6Address), port: endpoint.port)
        } else {
            // Must never happen
            fatalError()
        }
    }
}

extension Endpoint {
    func withReresolvedIP() throws -> Endpoint {
        #if os(iOS)
        let hostname: String
        switch host {
        case .name(let name, _):
            hostname = name
        case .ipv4(let address):
            hostname = "\(address)"
        case .ipv6(let address):
            hostname = "\(address)"
        @unknown default:
            fatalError()
        }

        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_DGRAM
        hints.ai_protocol = IPPROTO_UDP
        hints.ai_flags = 0 // We set this to zero so that we actually resolve this using DNS64

        var result: UnsafeMutablePointer<addrinfo>?
        defer {
            result.flatMap { freeaddrinfo($0) }
        }

        let errorCode = getaddrinfo(hostname, "\(self.port)", &hints, &result)
        if errorCode != 0 {
            throw DNSResolutionError(errorCode: errorCode, address: hostname)
        }

        let addrInfo = result!.pointee
        if let ipv4Address = IPv4Address(addrInfo: addrInfo) {
            return Endpoint(host: .ipv4(ipv4Address), port: port)
        } else if let ipv6Address = IPv6Address(addrInfo: addrInfo) {
            return Endpoint(host: .ipv6(ipv6Address), port: port)
        } else {
            fatalError()
        }
        #elseif os(macOS)
        return self
        #else
        #error("Unimplemented")
        #endif
    }
}

/// An error type describing DNS resolution error
public struct DNSResolutionError: LocalizedError {
    public let errorCode: Int32
    public let address: String

    init(errorCode: Int32, address: String) {
        self.errorCode = errorCode
        self.address = address
    }

    public var errorDescription: String? {
        return String(cString: gai_strerror(errorCode))
    }
}



import Foundation

extension Array {

    /// Returns an array containing the results of mapping the given closure over the sequence’s
    /// elements concurrently.
    ///
    /// - Parameters:
    ///   - queue: The queue for performing concurrent computations.
    ///            If the given queue is serial, the values are mapped in a serial fashion.
    ///            Pass `nil` to perform computations on the current queue.
    ///   - transform: the block to perform concurrent computations over the given element.
    /// - Returns: an array of concurrently computed values.
    func concurrentMap<U>(queue: DispatchQueue?, _ transform: (Element) -> U) -> [U] {
        var result = [U?](repeating: nil, count: self.count)
        let resultQueue = DispatchQueue(label: "ConcurrentMapQueue")

        let execute = queue?.sync ?? { $0() }

        execute {
            DispatchQueue.concurrentPerform(iterations: self.count) { index in
                let value = transform(self[index])
                resultQueue.sync {
                    result[index] = value
                }
            }
        }

        return result.map { $0! }
    }
}


// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import Network

extension IPv4Address {
    init?(addrInfo: addrinfo) {
        guard addrInfo.ai_family == AF_INET else { return nil }

        let addressData = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: MemoryLayout<sockaddr_in>.size) { ptr -> Data in
            return Data(bytes: &ptr.pointee.sin_addr, count: MemoryLayout<in_addr>.size)
        }

        self.init(addressData)
    }
}

extension IPv6Address {
    init?(addrInfo: addrinfo) {
        guard addrInfo.ai_family == AF_INET6 else { return nil }

        let addressData = addrInfo.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: MemoryLayout<sockaddr_in6>.size) { ptr -> Data in
            return Data(bytes: &ptr.pointee.sin6_addr, count: MemoryLayout<in6_addr>.size)
        }

        self.init(addressData)
    }
}
