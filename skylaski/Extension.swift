//
//  Extension.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit
import Foundation

@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var viewCornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var isCircle: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == viewCornerRadius
        }
        set {
            viewCornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : viewCornerRadius
        }
    }
    @IBInspectable var shadowColor: UIColor {
        set {
            layer.shadowColor = newValue.cgColor
        }
        get {
            guard let color = layer.shadowColor else {
                return .clear
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var maskBounds: Bool {
        set {
            layer.masksToBounds = newValue
        }
        get {
            return layer.masksToBounds
        }
    }
}

extension Notification.Name {
    static let notificationReload = Notification.Name("NotificationController")
    static let homeReload = Notification.Name("homeviewcontroller")
    static let movetohome = Notification.Name("movetohome")
    static let purchased = Notification.Name("ProductPurchased")
    static let failed = Notification.Name("ProductFailed")
    static let restored = Notification.Name("ProductRestored")
    static let deleted = Notification.Name("TunnelDeleted")
}

extension UserDefaults {

    class var token: String? {
        get {
            return standard.value(forKey: "token") as? String ?? ""
        }
        set {
            standard.set(newValue, forKey: "token")
        }
    }

    class var isLogged: Bool? {
        get {
            return standard.bool(forKey: "isLogged")
        }
        set {
            standard.set(newValue, forKey: "isLogged")
        }
    }



    class func removeUserDefaults() {

        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "isLogged")

    }
}

struct layoutModel {
    var top: NSLayoutYAxisAnchor? = nil
    var left: NSLayoutXAxisAnchor? = nil
    var bottom: NSLayoutYAxisAnchor? = nil
    var right: NSLayoutXAxisAnchor? = nil
    var centerX : NSLayoutXAxisAnchor? = nil
    var centerY : NSLayoutYAxisAnchor? = nil
    var paddingTop: CGFloat? = nil
    var paddingLeft: CGFloat? = nil
    var paddingBottom: CGFloat? = nil
    var paddingRight: CGFloat? = nil
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var enableInsets: Bool? = nil
}

extension UIView {


    func layoutAnchor (layout: layoutModel) {
        var topInset = CGFloat(0.0)
        var bottomInset = CGFloat(0.0)

        if #available(iOS 11, *), layout.enableInsets != nil {
            let insets = self.safeAreaInsets
            topInset = insets.top
            bottomInset = insets.bottom

        }

        translatesAutoresizingMaskIntoConstraints = false

        if let top = layout.top , let padding = layout.paddingTop {
            self.topAnchor.constraint(equalTo: top, constant: padding + topInset).isActive = true
        }
        if let left = layout.left , let padding = layout.paddingLeft{
            self.leftAnchor.constraint(equalTo: left, constant: padding).isActive = true
        }
        if let right = layout.right , let padding = layout.paddingRight{
            rightAnchor.constraint(equalTo: right, constant: -padding).isActive = true
        }
        if let bottom = layout.bottom , let padding = layout.paddingBottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -padding-bottomInset).isActive = true
        }
        if let centerX = layout.centerX{
            centerXAnchor.constraint(equalTo: centerX, constant: 0.0).isActive = true
        }
        if let centerY = layout.centerY{
            centerYAnchor.constraint(equalTo: centerY, constant: 0.0).isActive = true
        }
        if let height = layout.height, height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = layout.width , width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

    }
}


extension UIViewController {
    func showAlert(title: String = "Alert", message: String = "Payment failed!") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

