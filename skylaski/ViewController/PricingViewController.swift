//
//  PricingViewController.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit

class PricingViewController: UIViewController {
    @IBOutlet weak var tableViewList: UITableView!
    var arrayOfList = [ModelPricing]()
    var loadingView = LoadingView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateDisplay()
        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToHome), name: .purchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.restored), name: .restored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.failed), name: .failed, object: nil)
    }

    func updateDisplay() {

        for item in SkyAppStoreHelper.sharedInstance.products {
            let price = String(format: "%.2f", item.price.doubleValue / 12)
            arrayOfList.append(ModelPricing(title: item.localizedTitle, devices: item.localizedDescription, monthly: "\(item.priceLocale.currencySymbol ?? "$")\(price)per Month!", annually: "*\(item.priceLocale.currencySymbol ?? "$")\(item.price)Billed anually",id: item.productIdentifier))
        }
        tableViewList.reloadData()
    }
    @objc func moveToHome() {
        self.loadingView.removeLoadingScreen()
        DispatchQueue.main.async {
            let vc = NavigationController().mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func restored() {
        self.loadingView.removeLoadingScreen()
        print("restored")
    }

    @objc func failed() {
        self.loadingView.removeLoadingScreen()
    }
}
extension PricingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PricingTableViewCell", for: indexPath) as! PricingTableViewCell
        cell.itemModel = arrayOfList[indexPath.row]
        cell.delegate = self
        cell.parentVC = self
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { //PricingHeaderTableViewCell
        return tableView.dequeueReusableCell(withIdentifier: "PricingHeaderTableViewCell")
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
extension PricingViewController: PricingDelegate {
    func buttonTapped(item: ModelPricing) {
        loadingView.setLoadingScreen(view: self.view)
        SkyAppStoreHelper.sharedInstance.unlockPackage(item.id)
    }
}

struct ModelPricing {
    var title: String?
    var devices:String?
    var monthly: String?
    var annually: String?
    var id : String?
}

class PricingHeaderView: UIView {

}
