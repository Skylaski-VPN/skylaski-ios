//
//  VPNController.swift
//  skylaski
//
//  Created by Anilkumar on 20/05/21.
//

import UIKit
import WireGuardKit
import WireGuardKitGo
import WireGuardKitC

class VPNController: NSObject {


    private static var privateShared : VPNController?

    static var sharedInstance : VPNController { // change class to final to prevent override
            guard let uwShared = privateShared else {
                privateShared = VPNController()
                return privateShared!
            }
            return uwShared
        }

        class func destroy() {
            privateShared = nil
        }
    
    var tunnelsManager: TunnelsManager?

    var tunnelContainer: TunnelContainer?
    var tunnelViewModel: TunnelViewModel? = nil
    
    var appConstants = AppConstants.sharedInstance
    

    override init() {
        super.init()
        // Do any additional setup after loading the view.
        tunnelViewModel = TunnelViewModel(tunnelConfiguration: nil)
            TunnelsManager.create { [weak self] result in

                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let tunnelsManager):
                    self?.tunnelsManager = tunnelsManager
                    self?.tunnelsManager?.activationDelegate = self
                }
            }

    }

    func get() -> Bool {

        if appConstants.deviceId == "" {
            appConstants.getDeviceId()
        }

        self.tunnelContainer = self.tunnelsManager?.tunnel(named: appConstants.deviceId)
        guard let ctr = tunnelContainer else {
            print("no container")
            return false
        }
        if let result = self.tunnelContainer?.tunnelConfiguration {
            print("configgggggggg",result.asWgQuickConfig())


            do {

                let config = try TunnelConfiguration(fromWgQuickConfig: appConstants.config)


                if result.interface.addresses.first == config.interface.addresses.first {
                    appConstants.config = result.asWgQuickConfig()
                    self.tunnelViewModel?.applyConfiguration(other: result)
                    self.tunnelsManager?.startActivation(of: ctr)
                }
                else {
                    config.name  = appConstants.deviceId

                    self.tunnelsManager?.modify(tunnel: ctr, tunnelConfiguration: config, onDemandOption: .off, completionHandler: { (error) in
                        print(error?.alertText as Any)
                        print(error?.localizedDescription as Any)
                        print(error?.localizedUIString as Any)
                        self.tunnelViewModel?.applyConfiguration(other: config)
                        self.tunnelsManager?.startActivation(of: ctr)
                    })
                }
            }
            catch(let error) {
                print("alkdjfbgdfgdffdfkfjvddkdldldjl)))))))))))))))))))",error)
            }
        }
        return true
    }

    func updateDNS() {
        if appConstants.deviceId == "" {
            appConstants.getDeviceId()
        }

        self.tunnelContainer = self.tunnelsManager?.tunnel(named: appConstants.deviceId)

        guard let ctr = tunnelContainer else {
            print("no container")
            return
        }
        if let result = self.tunnelContainer?.tunnelConfiguration {
            print("confgggggg",result.asWgQuickConfig())

            do {
                self.tunnelViewModel?.applyConfiguration(other: result)
                
                // SETTING DNS, HARDCODED. MUST UPDATE
                //
                //
                //
                // VVVVVVVVVV
                self.tunnelViewModel?.interfaceData[.dns] = appConstants.dns
                appConstants.config = self.tunnelViewModel?.asWgQuickConfig() ?? ""
                let config = try TunnelConfiguration(fromWgQuickConfig: appConstants.config)
                config.name  = appConstants.deviceId
                self.tunnelsManager?.modify(tunnel: ctr, tunnelConfiguration: config, onDemandOption: .off, completionHandler: { (error) in
                    print(error?.alertText as Any)
                    print(error?.localizedDescription as Any)
                    print(error?.localizedUIString as Any)
                    self.tunnelsManager?.reload()
                    self.tunnelsManager?.refreshStatuses()
                })
            }
            catch(let error) {
                print("alkdjfbgdfgd)))))))))))))",error)
            }
        }
    }

    func setUp() {
        if self.tunnelsManager?.tunnel(named: appConstants.deviceId) != nil {

            _ = self.get()
        }
        else {

            do {

                let config = try TunnelConfiguration(fromWgQuickConfig: appConstants.config)
                config.name  = appConstants.deviceId
                self.tunnelViewModel?.applyConfiguration(other: config)
                
            }
            catch(let error) {
                print("alkdjfbgdfgdffdfkfjvddkdldldjl)))))))))))))))))))",error)

            }


            let tunnelSaveResult = tunnelViewModel?.save()
            switch tunnelSaveResult {
            case .error(let errorMessage):
                print("kjdfbgkdf+++++++++++++++++++++++",errorMessage)
            case .saved(let tunnelConfiguration):

                // We're adding a new tunnel
                self.tunnelsManager?.add(tunnelConfiguration: tunnelConfiguration,onDemandOption: .off) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error.alertText.message)
                    case .success(let tunnel):
                        self?.tunnelContainer = tunnel
                        print(tunnel.status.debugDescription, tunnel.name)
                        self?.tunnelsManager?.startActivation(of: tunnel)
                    }
                }

            case .none:
                print("sdkbvadjkbvfkdjbv__________________________")
                break
            }
        }
    }

    @objc func stop() {
        guard let ctr = tunnelContainer else {
            return
        }
        tunnelsManager?.startDeactivation(of: ctr)

    }

    func deleteAllVPN() {

        guard let mgr = self.tunnelsManager else {
            return
        }
        if mgr.numberOfTunnels() == 0 {
            NotificationCenter.default.post(name: .deleted , object: nil)
            return
        }

        for indexTunnel in 0..<mgr.numberOfTunnels() {
            let container = mgr.tunnel(at: indexTunnel)
                mgr.remove(tunnel: container) { error in
                    if error != nil {
                        print("Error removing tunnel: \(String(describing: error))")
                        return
                    }
                    else {
                        NotificationCenter.default.post(name: .deleted , object: nil)
                    }
            }
        }
    }

    @objc func deleteVPN() {

        guard let ctr = tunnelContainer else {
            return
        }

        self.tunnelsManager?.remove(tunnel: ctr) { error in
            if error != nil {
                print("Error removing tunnel: \(String(describing: error))")
                return
            }
        }
    }

}
extension VPNController : TunnelsManagerActivationDelegate {
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        print("hgsdvsdvf",error.localizedDescription)
    }

    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        print("success")
    }

    // I'm pretty sure this is where it's breaking on iOS 15
    // startActivation succeeds, but connection status goes from "connecting"
    // to "disconnecting" within a second.
    // Example log output:
    /*
     configgggggggg [Interface]
     PrivateKey = <REDACTED>
     Address = 10.120.193.82/32, fd56:7864:75da:29ae::ddb:1fc4/128
     DNS = 134.122.125.170
     MTU = 1280

     [Peer]
     PublicKey = FQqkfCecxd1QT6nFrEUBI35ZhPLqSQrSQtBgsPGlMnM=
     AllowedIPs = 0.0.0.0/0, ::/0
     Endpoint = 159.65.107.66:51820
     PersistentKeepalive = 21

     2021-12-04 14:27:56.248381-0600 skylaski[2258:674669] startActivation: Entering (tunnel: 8765EDE4-E16D-409F-9EED-51569E0C85C2)
     2021-12-04 14:27:56.248431-0600 skylaski[2258:674669] startActivation: Starting tunnel
     2021-12-04 14:27:56.248685-0600 skylaski[2258:674669] startActivation: Success
     success
     2021-12-04 14:27:56.253054-0600 skylaski[2258:674669] Tunnel '8765EDE4-E16D-409F-9EED-51569E0C85C2' connection status changed to 'connecting'
     2021-12-04 14:27:56.403236-0600 skylaski[2258:674669] Tunnel '8765EDE4-E16D-409F-9EED-51569E0C85C2' connection status changed to 'disconnecting'
     2021-12-04 14:27:56.670943-0600 skylaski[2258:674669] Tunnel '8765EDE4-E16D-409F-9EED-51569E0C85C2' connection status changed to 'disconnected'
     smdjfbsjdfbjh alertTunnelActivationFailureMessage
     2021-12-04 14:28:01.249651-0600 skylaski[2258:674669] Status update notification timeout for tunnel '8765EDE4-E16D-409F-9EED-51569E0C85C2'. Tunnel status is now 'disconnected'.
     */
    
    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        print("smdjfbsjdfbjh",error.alertText.message)
    }

    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
         print("successss")
        NotificationCenter.default.post(name: .homeReload , object: nil)
    }

}

