//
//  NavigationController.swift
//  PPE
//
//  Created by Anilkumar on 20/04/21.
//

import UIKit

class NavigationController: NSObject {

    let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)

    var navigationCtrlr: UINavigationController?

    private static var privateSharedInstance: NavigationController?
    static var sharedInstance: NavigationController {
      if privateSharedInstance == nil {
        privateSharedInstance = NavigationController()
      }
      return privateSharedInstance!
    }
    class func destroy() {
      privateSharedInstance = nil
    }

      func getCurrentNavigation() {
          navigationCtrlr = UIApplication.shared.keyWindow!.rootViewController! as? UINavigationController
      }

    static func getCurrentViewController(_ vc: UIViewController) -> UIViewController? {
      if let presentViewControllers = vc.presentedViewController {
        return getCurrentViewController(presentViewControllers)
      }
      else if let splitViewControllers = vc as? UISplitViewController, splitViewControllers.viewControllers.count > 0 {
        return getCurrentViewController(splitViewControllers.viewControllers.last!)
      }
      else if let navigationControllers = vc as? UINavigationController, navigationControllers.viewControllers.count > 0 {
        return getCurrentViewController(navigationControllers.topViewController!)
      }
      else if let tabBarViewControllers = vc as? UITabBarController ,let selectedViewController = tabBarViewControllers.selectedViewController {
          return getCurrentViewController(selectedViewController)
      }
      return vc
    }
  }
