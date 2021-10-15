//
//  ServerCommunicationController.swift
//  PPE
//
//  Created by Anilkumar on 20/04/21.
//

import UIKit

class ServerCommunicationController: NSObject {

    static func callForPost(urlString:String, params: Dictionary<String, Any> ,completion:@escaping (_ success: Bool,_ response : Data?, _ error: String) -> Void) -> () {

        if !Connectivity().isConnection() {
            if let currentVC = UIApplication.topViewController() as? PricingViewController {
                currentVC.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            }
            return
        }
        if UserDefaults.token == "" {
            return
        }

        print(params,UserDefaults.token as Any, urlString)
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + (UserDefaults.token ?? ""), forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let response = response {
//                print(response)
//                            }
            if let data = data {

                print(String(data: data, encoding: .utf8)!)
                completion(true,data,"")
            }
            else {
                completion(false,nil,error?.localizedDescription ?? "Invalid")
            }
        }.resume()

    }

    static func callForGet(urlString:String,completion:@escaping (_ success: Bool,_ response : Any?, _ error: String) -> Void) -> () {
        if !Connectivity().isConnection() {
            if let currentVC = UIApplication.topViewController() as? PricingViewController {
                currentVC.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            }
            return
        }


        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + (UserDefaults.token ?? ""), forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //                if let response = response {
            //                    print(response)
            //                }
            if let data = data {
                completion(true,data,"")
            }
            else {
                completion(false,nil,error?.localizedDescription ?? "")
            }
        }.resume()

    }
}
