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

    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        print("smdjfbsjdfbjh",error.alertText.message)
    }

    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
         print("successss")
        NotificationCenter.default.post(name: .homeReload , object: nil)
    }

}

