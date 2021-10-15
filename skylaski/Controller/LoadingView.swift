//
//  LoadingView.swift
//  furthr
//
//  Created by AITMAC6 on 30/03/21.
//  Copyright © 2020 AIT. All rights reserved.
//

import UIKit

class LoadingView {
    private let viewBG = UIView()
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
    private let loadingLabel = UILabel()

    func setLoadingScreen(view: UIView) {
        viewBG.frame = view.frame
        viewBG.backgroundColor = .clear
        loadingView.layer.masksToBounds = true
        loadingView.layer.cornerRadius = 15
        loadingView.backgroundColor = UIColor.black
        loadingView.alpha = 0.85

        spinner.style = .whiteLarge
        spinner.startAnimating()

        loadingView.addSubview(spinner)
        viewBG.addSubview(loadingView)
        view.addSubview(viewBG)

        loadingView.layoutAnchor(layout: layoutModel(top: nil, left: nil, bottom: nil, right: nil, centerX: view.centerXAnchor, centerY: view.centerYAnchor, paddingTop: 0.0, paddingLeft: 0.0, paddingBottom: 0.0, paddingRight: 0.0, width: 75, height: 75, enableInsets: true))

        spinner.layoutAnchor(layout: layoutModel(top: nil, left: nil, bottom: nil, right: nil, centerX: loadingView.centerXAnchor, centerY: loadingView.centerYAnchor, paddingTop: 0.0, paddingLeft: 0.0, paddingBottom: 0.0, paddingRight: 0.0, width: 35, height: 35, enableInsets: true))
    }

    func removeLoadingScreen() {
        DispatchQueue.main.async { [self] in
            spinner.hidesWhenStopped = true
            spinner.stopAnimating()
            spinner.isHidden = true
            loadingView.removeFromSuperview()
            loadingLabel.removeFromSuperview()
            viewBG.removeFromSuperview()
        }

    }
}





class Connectivity : NSObject {

    var reachability: Reachability?
    let hostName = "google.com"
    override init() {
        super.init()
        self.setupReachability()
    }

    private func setupReachability() {
        self.reachability = try? Reachability(hostname: hostName)
        print("--- set up with host name: \(hostName )")

        do {
            try reachability?.startNotifier()
        } catch {

            return
        }
    }

    func isConnection() -> Bool {
        if reachability == nil {
            self.setupReachability()
        }
        return reachability?.connection == .some(.cellular) || reachability?.connection == .some(.wifi)
    }
}
