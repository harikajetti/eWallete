//
//  SettingViewController.swift
//  eWallete
//
//  Created by HARIKA on 07/07/17.
//  Copyright © 2017 HARIKAharika. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

   
    @IBOutlet weak var currencyTextField:
    UITextField!
    @IBOutlet weak var dateFormatTextField: UITextField!
    
    var datePicker: UIPickerView!
    var currencyPicker: UIPickerView!
    
    let currencyArray = ["€" , "$", "£", "¥", "₽", "HKD", "CHF", "Kč", "kr", "﷼", "₪", "₩", "Ls", "Rs", "﷼"]
    
    let currencyStringArray = ["EUR, €", "USD, $", "GBP, £", "CNY, ¥", "RUB, ₽", "HKD", "CHF", "CZK, Kč", "DKK, kr", "IRR, ﷼", "ILS, ₪", "KRW, ₩", "Lat, Ls", "Rupee, Rs", "QAR, ﷼"]
    
    let dateFormatArray = ["dd MMMM yyyy", "MMMM dd yyyy", "yyyy MMMM dd"]
    let dateFormatStringArray = ["Day Month Year", "Month Day Year", "Year Month Day"]
    
    var currency = ""
    var dateFormat = ""
    var currencyString = ""
    var dateFormatString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        datePicker = UIPickerView()
        datePicker.delegate = self
        currencyPicker = UIPickerView()
        currencyPicker.delegate = self
        currencyTextField.inputView = currencyPicker
        currencyTextField.delegate = self
        dateFormatTextField.inputView = datePicker
        dateFormatTextField.delegate = self

        
        loadSettings()
        updateUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// Mark: PickerViewDataSourc
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePicker {
            return dateFormatStringArray.count
        } else {
            return currencyStringArray.count
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == datePicker {
            return dateFormatStringArray[row]
        } else {
            return currencyStringArray[row]
        }

        
    }
    
    //Mark: PickerViewDelagate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == datePicker {
            dateFormat = dateFormatArray[row]
            dateFormatString = dateFormatStringArray[row]
        } else {
            currency = currencyArray[row]
            currencyString = currencyStringArray[row]
        }
        updateUI()
        saveSettings()

    }
    
    // MARK: TextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == currencyTextField {
            if currencyString == "" {
                currencyString = currencyStringArray[0]
            }
            currencyTextField.text = currencyString
        }
        if textField == dateFormatTextField {
            if dateFormatString == "" {
                dateFormatString = dateFormatStringArray[0]
                
            }
            dateFormatTextField.text = dateFormatString
            
        }
    }
    
    //MARK: helper Functions
    
    func loadSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        currencyString = userDefaults.objectForKey(kCURRENCYSTRING) as! String
        currency = userDefaults.objectForKey(kCURRENCY) as! String
        dateFormatString = userDefaults.objectForKey(kDATEFORMATSTRING) as! String
        dateFormat = userDefaults.objectForKey(kDATEFORMAT) as! String
    }
    
    func saveSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(currencyString, forKey: kCURRENCYSTRING )
        userDefaults.setObject(currency, forKey: kCURRENCY)
        userDefaults.setObject(dateFormatString, forKey: kDATEFORMATSTRING)
        userDefaults.setObject(dateFormat, forKey: kDATEFORMAT)
        userDefaults.synchronize()
    }
    
    func updateUI() {
        currencyTextField.text =  currencyString
        dateFormatTextField.text = dateFormatString
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        
        self.view.endEditing(false)
    }
    
}
