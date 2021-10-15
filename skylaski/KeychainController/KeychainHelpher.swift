
import UIKit

class KeychainHelpher {

    private var store = KeychainController()

    private static var privateSharedInstance: KeychainHelpher?

    static var sharedInstance: KeychainHelpher {
        if privateSharedInstance == nil {
            privateSharedInstance = KeychainHelpher()
        }
        return privateSharedInstance!
    }
    class func destroy() {
        privateSharedInstance = nil
    }

    func updateDeviceId(result: String){
        _ = store.archive(result, key: "deviceID")
    }


    func getDeviceId() -> String {
        let unArchiveId = store.unarchive(objectForKey: "deviceID") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func updateLcoation(result: String){
        _ = store.archive(result, key: "locationId")
    }


    func getLocation() -> String {
        let unArchiveId = store.unarchive(objectForKey: "locationId") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func updateKeys(strPrivate: String, strPublic: String){
        _ = store.archive(strPrivate, key: "privateKey")
        _ = store.archive(strPublic, key: "publicKey")
    }


    func getPublicKey() -> String {
        let unArchiveId = store.unarchive(objectForKey: "publicKey") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func getPrivateKey() -> String {
        let unArchiveId = store.unarchive(objectForKey: "privateKey") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func updateClientId(clientID: String){
        _ = store.archive(clientID, key: "clientID")
    }

    func updateClientToken( clientToken: String){
        _ = store.archive(clientToken, key: "clientToken")
    }


    func getClientId() -> String {
        let unArchiveId = store.unarchive(objectForKey: "clientID") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func getClientToken() -> String {
        let unArchiveId = store.unarchive(objectForKey: "clientToken") as? String
        if unArchiveId != nil{
            return unArchiveId!
        }else{
            return ""
        }
    }

    func removeValuesFromStrongBox(){
        store.remove(key: "privateKey")
        store.remove(key: "publicKey")
        store.remove(key: "clientID")
        store.remove(key: "clientToken")
        store.remove(key: "locationId")
    }
}
