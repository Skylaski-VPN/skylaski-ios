//
//  HomeButtonTableViewCell.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit
protocol HomeButtonDelegate {
    func buttonLogout()
    func buttonTest()
    func buttonProfile()
}
class HomeButtonTableViewCell: UITableViewCell {
    var delegate: HomeButtonDelegate?
    var parentVC = HomeViewController()
    @IBOutlet weak var buttonProfile:UIButton!
    @IBOutlet weak var buttonTest:UIButton!
    @IBOutlet weak var buttonLogout:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonProfile(_ sender: UIButton){
        if !Connectivity().isConnection() {
            if let currentVC = UIApplication.topViewController() as? PricingViewController {
                currentVC.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            }
            return
        }
        delegate?.buttonProfile()
    }
    @IBAction func buttonTest(_ sender: UIButton){
        delegate?.buttonTest()
    }
    @IBAction func buttonLogout(_ sender: UIButton){
        if !Connectivity().isConnection() {
            parentVC.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            return
        }
        delegate?.buttonLogout()
    }
}
