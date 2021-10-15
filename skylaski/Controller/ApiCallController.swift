//
//  ApiCallController.swift
//  skylaski
//
//  Created by Anilkumar on 07/05/21.
//

import UIKit
protocol APICallDelegate {
    func reloadLocation()
    func reloadDNS()
    func deleteReload(status:ApiSuccessResponse)
    func createClientCanceled(status:ApiSuccessResponse)
    func locationChangeStartVpn()
}


class ApiCallController : NSObject {
    let appConstants = AppDelegate().appConstants
    var delegate: APICallDelegate?
    func createClient() {
        let params = ["cmd": cmdType.create, "local_uid": appConstants.deviceId, "name": appConstants.deviceId, "pub_key":appConstants.publicKey, "dns_type": appConstants.dnsType]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params) { (success, response, error) in

            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiResponse.self, from: responseInfo )
                if responseDetails?.success ?? false {
                    self.appConstants.clientID = responseDetails?.result?.client_uid ?? ""
                    self.appConstants.clientToken = responseDetails?.result?.client_token ?? ""
                    self.getClientConfig()
                    print(responseDetails as Any)
                }
                else {
                    let response = try? JSONDecoder().decode(ApiSuccessResponse.self, from: responseInfo )
                    self.delegate?.createClientCanceled(status: response ?? ApiSuccessResponse())
                }
            }
        }
    }

    func getClientConfig(isLocation : Bool = false) {

        if appConstants.config != "" , !isLocation {
            if self.appConstants.locations.count == 0 {
                self.getLocations()
            }
            else {
                self.delegate?.reloadLocation()
            }
        }
        else {

        let params = ["cmd": cmdType.client_config, "local_uid": appConstants.deviceId]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params) { (success, response, error) in
            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiResponse.self, from: responseInfo)
                print(responseDetails as Any)

                if let clientInfo = responseDetails?.result , clientInfo.client_uid != "" {
                    self.appConstants.clientID = clientInfo.client_uid ?? ""
                    self.appConstants.clientToken = clientInfo.client_token ?? ""
                    if let config = clientInfo.config {
                        print(config)
                        let value = config.replacingOccurrences(of: "<PRIVATEKEY>", with: self.appConstants.privateKey)
                        print(value)
                        self.appConstants.config = value
                    }

                    if self.appConstants.locations.count == 0 {
                        self.getLocations()
                    }
                    else {
                        self.delegate?.reloadLocation()
                    }

                    if isLocation {
                        self.delegate?.locationChangeStartVpn()
                    }
                    print(responseDetails as Any)
                }
                else if !(responseDetails?.success ?? false) {
                    self.createClient()
                }

            }
        }
    }
    }

    private func getLocations() {
        let params = ["cmd": cmdType.locations,"client_uid": appConstants.clientID, "client_token": appConstants.clientToken]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params) { (success, response, error) in
            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(LcoationResponse.self, from: responseInfo)
                AppConstants.sharedInstance.locations = responseDetails?.result ?? [locationResponse]()
                print(responseDetails as Any)
                self.delegate?.reloadLocation()
            }
        }
    }

    func getDns() {
        // block = 3, unblock = 2
        let params = ["cmd": cmdType.dns,"client_uid": appConstants.clientID, "client_token": appConstants.clientToken,"dns_type":appConstants.dnsType]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params) { (success, response, error) in

            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiResponse.self, from: responseInfo)
                if responseDetails?.success ?? false {
                    self.appConstants.dns = responseDetails?.result?.dns_server ?? self.appConstants.dns
                    self.delegate?.reloadDNS()
                }
                print(responseDetails as Any)
            }
        }
    }

    func getPlans(isFromHome: Bool = false) {
        let params = ["cmd": cmdType.plan]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.user, params: params) { (success, response, error) in
            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(PlanResponse.self, from: responseInfo)
                print(responseDetails as Any)
                if responseDetails?.success ?? false {
                    self.appConstants.plansDetails = responseDetails?.result ?? PlanResultData()
                    if !isFromHome {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            NotificationCenter.default.post(name: .movetohome , object: nil)
                        }
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NotificationCenter.default.post(name: .notificationReload , object: nil)
                    }
                }
            }
        }
    }

    func attachLocation() {
        let params = ["cmd": cmdType.attachLocation,"client_uid": appConstants.clientID, "client_token": appConstants.clientToken,"loc_uid":appConstants.selectedLocation.loc_uid]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params as Dictionary<String, Any>) { (success, response, error) in
            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiResponse.self, from: responseInfo)
                if responseDetails?.success ?? false {
                    self.getClientConfig(isLocation: true)
                }
                print(responseDetails as Any)
            }
        }
    }

    func detachLocation() {
        let params = ["cmd": cmdType.detachLocation,"client_uid": appConstants.clientID, "client_token": appConstants.clientToken]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.client, params: params) { (success, response, error) in
            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(DeLcoationResponse.self, from: responseInfo)
                print(responseDetails as Any)
                if responseDetails?.success ?? false {
                    self.attachLocation()
                }
            }
        }
    }

    func deleteClient() {
        let params = ["cmd": cmdType.deleteClient,"local_uid": appConstants.deviceId]

        ServerCommunicationController.callForPost(urlString: APPURL.domainAPi + endPoint.user, params: params) { (success, response, error) in

            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiSuccessResponse.self, from: responseInfo)
                print(responseDetails as Any)
                self.delegate?.deleteReload(status: responseDetails ?? ApiSuccessResponse())
            }
        }
    }

    func updatePayment(params : [String: Any]) {
        ServerCommunicationController.callForPost(urlString: APPURL.domain + endPoint.payment, params: params) { (success, response, error) in

            if success, let responseInfo = response {
                let responseDetails = try? JSONDecoder().decode(ApiSuccessResponse.self, from: responseInfo)
                print(responseDetails as Any)
                if responseDetails?.success ?? false {
                    NotificationCenter.default.post(name: .purchased, object: nil)
                }
                else {
                    NotificationCenter.default.post(name: .failed, object: nil)
                    if let currentVC = UIApplication.topViewController() as? PricingViewController {
                        currentVC.showAlert( message: responseDetails?.message ?? "Payment failed!!")
                    }
                }
            }
            else {
                NotificationCenter.default.post(name: .failed, object: nil)
                if let currentVC = UIApplication.topViewController() {
                    currentVC.showAlert( message: "Payment failed")
                }
            }
        }
    }
}

