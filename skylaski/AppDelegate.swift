//
//  AppDelegate.swift
//  skylaski
//
//  Created by Anilkumar on 07/05/21.
//

import UIKit
import WireGuardKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appConstants = AppConstants.sharedInstance
    var vpnController = VPNController.sharedInstance
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SkyAppStoreHelper.sharedInstance.getPriceOfProduct()
        if UserDefaults.isLogged ?? false {
            ApiCallController().getPlans()
            self.moveToHome()
        }
        else {
            self.moveToLogin()
        }
        return true
    }
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("delegate",url)
        let params = url.params()
        if let token = params["token"] as? String {
            print(token)
            let privateKey = Curve25519.generatePrivateKey()
            print(Curve25519.generatePublicKey(fromPrivateKey: privateKey).base64Key() ?? "")
            UserDefaults.token = token
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.dismiss(animated: true, completion: nil)
            }
            ApiCallController().getPlans()
        }

        return true
    }
    @objc func postPricingNotify() {
        NotificationCenter.default.post(name: .notificationReload , object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if UserDefaults.isLogged ?? false {
            NotificationCenter.default.post(name: .homeReload , object: nil)
        }
    }

    func moveToLogin() {
        UserDefaults.removeUserDefaults()
        KeychainHelpher.sharedInstance.removeValuesFromStrongBox()


        let mainViewController = NavigationController.sharedInstance.mainStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let viewNavigationController = UINavigationController(rootViewController: mainViewController)
        viewNavigationController.isNavigationBarHidden = true
        self.window?.rootViewController = viewNavigationController
    }
    func moveToHome() {
        let mainViewController = NavigationController.sharedInstance.mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let viewNavigationController = UINavigationController(rootViewController: mainViewController)
        viewNavigationController.isNavigationBarHidden = true
        self.window?.rootViewController = viewNavigationController
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        var ctr = controller
        DispatchQueue.main.async {
            if ctr == nil {
                ctr = UIApplication.shared.keyWindow?.rootViewController
            }
            if let navigationController = ctr as? UINavigationController {
                ctr = topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = ctr as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    ctr = topViewController(controller: selected)
                }
            }
            if let presented = ctr?.presentedViewController {
                ctr = topViewController(controller: presented)
            }

        }
        return ctr
    }
}
