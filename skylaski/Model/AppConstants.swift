//
//  AppConstants.swift
//  skylaski
//
//  Created by Anilkumar on 21/05/21.
//

import UIKit

class AppConstants : NSObject {

    private static var privateShared : AppConstants?

    static var sharedInstance : AppConstants { // change class to final to prevent override
            guard let uwShared = privateShared else {
                privateShared = AppConstants()
                return privateShared!
            }
            return uwShared
        }

        class func destroy() {
            privateShared = nil
        }

    var publicKey = ""
    var privateKey = ""
    var dnsType = ""   // block - 3, unblock - 2
    var deviceId = ""

    var clientID : String {
        set {
            KeychainHelpher.sharedInstance.updateClientId(clientID: newValue)
        }
        get {
            return KeychainHelpher.sharedInstance.getClientId()
        }
    }
    var clientToken : String {
        set {
            KeychainHelpher.sharedInstance.updateClientToken(clientToken: newValue)
        }
        get {
            return KeychainHelpher.sharedInstance.getClientToken()
        }
    }

    var locations = [locationResponse]()
    var selectedLocation : locationResponse {
        set {
            KeychainHelpher.sharedInstance.updateLcoation(result: newValue.loc_uid ?? "")
        }
        get {
            if self.locations.count > 0, let foo = self.locations.first(where: {$0.loc_uid == KeychainHelpher.sharedInstance.getLocation()}) {
                   return foo
            }
            return locationResponse()
        }
    }

    var plansDetails = PlanResultData()

    var dns = ""
    
    var purchasing = false

    var config = ""

    var viaLogin = false

    override init() {
        super.init()
        dnsType = "3"
        self.getNewPublicKey()
    }

    func getNewPublicKey() {
        self.getDeviceId()
        if KeychainHelpher.sharedInstance.getPrivateKey() == "" || KeychainHelpher.sharedInstance.getPublicKey() == "" {
            let priKey = Curve25519.generatePrivateKey()
            KeychainHelpher.sharedInstance.updateKeys(strPrivate: priKey.base64Key() ?? "", strPublic: Curve25519.generatePublicKey(fromPrivateKey: priKey).base64Key() ?? "")
        }
        privateKey = KeychainHelpher.sharedInstance.getPrivateKey()
        publicKey = KeychainHelpher.sharedInstance.getPublicKey()
    }

    func getVPNStatus() -> Bool {
        return AppDelegate().vpnController.tunnelContainer?.status == .some(.active)
    }

    func getDeviceId() {
        if KeychainHelpher.sharedInstance.getDeviceId() == "" {
            deviceId = UUID().uuidString
            KeychainHelpher.sharedInstance.updateDeviceId(result: deviceId)
        }
        else {
            deviceId = KeychainHelpher.sharedInstance.getDeviceId()
        }
    }
}
