//
//  HomeViewController.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableViewList: UITableView!
    var apiController = ApiCallController()
    var loadingView = LoadingView()
    var appDelegate = AppDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewList.keyboardDismissMode = .onDrag
        apiController.delegate = self
        loadingView.setLoadingScreen(view: self.view)
        apiController.appConstants.getNewPublicKey()
        apiController.getClientConfig()
        UserDefaults.isLogged = true
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: .homeReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callLogoutApi), name: .deleted, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppConstants.sharedInstance.plansDetails.product?.name == "" || AppConstants.sharedInstance.plansDetails.product?.name == nil {
            apiController.getPlans(isFromHome: true)
        }
    }

    @objc func reload() {
        tableViewList.reloadData()
    }
    @objc func callLogoutApi() {
        self.perform(#selector(deleteClient), with: nil, afterDelay: 0.2)
    }

    @objc private func deleteClient() {
        self.apiController.deleteClient()
    }
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeLocationTableViewCell", for: indexPath) as! HomeLocationTableViewCell
            cell.parentVC = self
            cell.delegate = self
            cell.item = AppConstants.sharedInstance.locations
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDeviceInfoTableViewCell", for: indexPath) as! HomeDeviceInfoTableViewCell
            cell.item = AppConstants.sharedInstance.plansDetails
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeButtonTableViewCell", for: indexPath) as! HomeButtonTableViewCell
            cell.delegate = self
            cell.parentVC = self
            return cell
        }

    }
}
extension HomeViewController: HomeButtonDelegate {
    func buttonLogout() {

        let alert = UIAlertController(title: "Alert", message: "Do you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (item) in
            self.loadingView.setLoadingScreen(view: self.view)
            if AppConstants.sharedInstance.getVPNStatus() {
                self.appDelegate.vpnController.stop()
            }
            self.appDelegate.vpnController.deleteAllVPN()

        }))
        self.present(alert, animated: true, completion: nil)

    }
    func buttonTest() {
        let url = URL(string: APPURL.domain + endPoint.checkIp)
        UIApplication.shared.open(url!)
    }
    func buttonProfile() {
        let url = URL(string: APPURL.domain + endPoint.login)
        UIApplication.shared.open(url!)
    }

    @objc func logout() {
        UserDefaults.removeUserDefaults()
        KeychainHelpher.sharedInstance.removeValuesFromStrongBox()
        AppConstants.destroy()
        VPNController.destroy()

        self.loadingView.removeLoadingScreen()
        DispatchQueue.main.async {
            let mainViewController = NavigationController.sharedInstance.mainStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let viewNavigationController = UINavigationController(rootViewController: mainViewController)
            viewNavigationController.isNavigationBarHidden = true
            UIApplication.shared.windows.first?.rootViewController = viewNavigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
extension HomeViewController: APICallDelegate {
    func locationChangeStartVpn() {
        appDelegate.vpnController.setUp()
    }

    func deleteReload(status: ApiSuccessResponse) {
        if status.success ?? false {
            self.logout()
        }
        else {
            loadingView.removeLoadingScreen()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert", message: status.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func reloadLocation() {
        DispatchQueue.main.async {
            self.tableViewList.reloadData()
        }
        loadingView.removeLoadingScreen()
    }
    func reloadDNS() {
        appDelegate.vpnController.updateDNS()
        loadingView.removeLoadingScreen()
    }
    func createClientCanceled(status: ApiSuccessResponse) {
        loadingView.removeLoadingScreen()
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: status.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (item) in
                self.loadingView.setLoadingScreen(view: self.view)
                self.logout()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: HomeLocationTableViewCellDelegate {
    func selectedLocation() {
        loadingView.setLoadingScreen(view: self.view)
        self.perform(#selector(self.detachLocation), with: nil, afterDelay: 0.3)
    }
    func selectedTrackers() {
        loadingView.setLoadingScreen(view: self.view)
        apiController.getDns()
    }


    @objc func detachLocation() {
        apiController.detachLocation()
    }
}
