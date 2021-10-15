//
//  PricingTableViewCell.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit
protocol PricingDelegate {
    func buttonTapped(item:ModelPricing)
}
class PricingTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDevice: UILabel!
    @IBOutlet weak var labelMonthPrice: UILabel!
    @IBOutlet weak var labelAnnualPrice: UILabel!
    var delegate: PricingDelegate?
    var parentVC = PricingViewController()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var itemModel: ModelPricing? = nil {
        didSet {
            labelTitle.text = itemModel?.title
            labelDevice.text = itemModel?.devices
            labelMonthPrice.text = itemModel?.monthly
            labelAnnualPrice.text = itemModel?.annually
        }
    }

    @IBAction func buttonSignUp(_ sender: UIButton) {
        if !Connectivity().isConnection() {
            parentVC.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            return
        }
        delegate?.buttonTapped(item: itemModel ?? ModelPricing())
    }
}
