//
//  HomeLocationTableViewCell.swift
//  skylaski
//
//  Created by Anilkumar on 17/05/21.
//

import UIKit
protocol HomeLocationTableViewCellDelegate {
    func selectedLocation()
    func selectedTrackers()
}

class HomeLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBOutlet weak var buttonConnection: UISwitch!
    @IBOutlet weak var buttonTrackers: UISwitch!

    var pickerView = UIPickerView()
    private var toolbar = UIToolbar()
    private var isCancel = false

    private var arrayOfList = [locationResponse]()
    var parentVC = HomeViewController()
    var appDelegate = AppDelegate()
    var delegate: HomeLocationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.delegate = self
        textFieldLocation.inputView = pickerView
        textFieldLocation.placeholder = "Select Location"
        buttonConnection.isOn = false
        buttonTrackers.isOn = AppConstants.sharedInstance.dnsType == "3"

        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        textFieldLocation.inputAccessoryView = toolbar

    }
    @objc func donedatePicker(){
        self.endEditing(true)
        appDelegate.vpnController.stop()
        buttonConnection.isOn = false
        let index = pickerView.selectedRow(inComponent: 0)
        textFieldLocation.text = arrayOfList[index].name
        AppConstants.sharedInstance.selectedLocation = arrayOfList[index]
        delegate?.selectedLocation()
    }

    @objc func cancelDatePicker(){
        isCancel = true
        self.endEditing(true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var item : [locationResponse]? = nil {
        didSet {
            arrayOfList = item ?? [locationResponse]()
            buttonTrackers.isOn = AppConstants.sharedInstance.dnsType == "3"
            textFieldLocation.text = AppConstants.sharedInstance.selectedLocation.name
            buttonConnection.isOn = AppConstants.sharedInstance.getVPNStatus()
        }
    }

    @IBAction func buttonConnection(_ sender: UISwitch) {
        print(sender.isOn)
        if AppConstants.sharedInstance.selectedLocation.name != "" {

            if sender.isOn , textFieldLocation.text != "" {
                appDelegate.vpnController.setUp()
            }
            else if textFieldLocation.text == "" {
                buttonConnection.isOn = false
                let alert = UIAlertController(title: "Alert", message: "Choose the location first", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                parentVC.present(alert, animated: true, completion: nil)
            }
            else {
                appDelegate.vpnController.stop()
            }
        }
    }

    @IBAction func buttonTrackers(_ sender: UISwitch) {
        print(sender.isOn)
        AppConstants.sharedInstance.dnsType = sender.isOn ? "3" : "2"
        delegate?.selectedTrackers()
    }

    @IBAction func buttonLocation(_ sender: UIButton) {
        textFieldLocation.becomeFirstResponder()
    }
}
extension HomeLocationTableViewCell: UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfList.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfList[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if arrayOfList.count > row {
            AppConstants.sharedInstance.selectedLocation = arrayOfList[row]
        }
    }
}
