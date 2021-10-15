//
//  HomeDeviceInfoTableViewCell.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit

class HomeDeviceInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var labelPlanTitle:UILabel!
    @IBOutlet weak var labelExpires:UILabel!
    @IBOutlet weak var labelDeviceId:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var item : PlanResultData? = nil {
        didSet {
            labelPlanTitle.text = item?.product?.name
            labelExpires.text = "Expires: " + (item?.plan?.expiration ?? "")
            labelDeviceId.text = "Device ID: " + AppConstants.sharedInstance.deviceId
        }
    }
}
