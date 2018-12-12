//
//  PostViewController.swift
//  Assignment
//
//  Created by Dev on 11/12/18.
//  Copyright © 2018 Dev. All rights reserved.
//
//constraintDescriptionHt

import UIKit
import IQKeyboardManager
import SkyFloatingLabelTextField

class PostViewController: UIViewController {
    //   private var floatingTextView : UIFloatLabelTextView? = nil
    var arrSelectedCategories = [Int]()
    @IBOutlet weak var txtBudget: SkyFloatingLabelTextField!
    @IBOutlet weak var txtCategories: SkyFloatingLabelTextField!
    @IBOutlet weak var txtTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLocation: SkyFloatingLabelTextField!
    
    @IBOutlet weak var lblDescLine: UILabel!
    @IBOutlet weak var viewPostDescription: UIView!
    @IBOutlet weak var lblTitleDecsription: UILabel!
    @IBOutlet weak var lblcategoryLine: UILabel!
    @IBOutlet weak var btnCounty: UIButton!
    @IBOutlet weak var lblDescriptionCharacterLeft: UILabel!
    @IBOutlet weak var txtJoinTerms: SkyFloatingLabelTextField!
    @IBOutlet weak var lblTitleCharacLeft: UILabel!
    @IBOutlet weak var txtStartDate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPaymentMethod: SkyFloatingLabelTextField!
    @IBOutlet weak var txtRate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDescription: IQTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setUp()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    //MARK:-Intial setup
    func setUp(){
        //set up placeholder for description
        NSUtility.addTapGestureOnView(view: self.view, cancelTouchInView: true, viewController: self)
        //        self.floatingTextView = PostViewModel.setMyFloatingTextView(txtView: self.txtDescription)
        //        self.floatingTextView?.delegate = self
        //        self.txtDescription.addSubview(self.floatingTextView!)
    }
    
    //MARK:- check text field type to perform particular action
    func checkForTextFieldType(type:Int){
        if type  == 3{
            PostViewModel.openCategoryPicker(fromViewController: self,selectedCategories: arrSelectedCategories) { (categories) in
                if categories.count == 0{
                    self.arrSelectedCategories.removeAll()
                    self.txtCategories.text = ""
                    return
                }
                self.arrSelectedCategories = categories
                self.txtCategories.text = categories.count == 1 ? "\(categories.count) Catgeory Selected" :  "\(categories.count) Catgeories Selected"
            }
        }
        else if type  == 5{
            PostViewModel.pickOption(fromViewController: self, forCategory: EnumOptionTypeStatus.Rate.rawValue) { (str) in
                self.txtRate.text = str
            }
        }
        else if type  == 6{
            PostViewModel.pickOption(fromViewController: self, forCategory: EnumOptionTypeStatus.Payment.rawValue) { (str) in
                self.txtPaymentMethod.text = str
            }
        }
        else if type  == 7 {
            PostViewModel.openLocationPicker(fromViewController: self) { (location) in
                self.txtLocation.text = location
            }
        }
        else if type  == 8{
            PostViewModel.openDatePicker(fromViewController: self) { (str) in
                self.txtStartDate.text = str
            }
            
        }
        else if type  == 9{
            PostViewModel.pickOption(fromViewController: self, forCategory: EnumOptionTypeStatus.JoinTerm.rawValue) { (str) in
                self.txtJoinTerms.text = str
            }
        }
    }
    //MARK:-Button actions
    @IBAction func actionCountry(_ sender: Any) {
        
        PostViewModel.openCountryPicker(fromViewController: self) { (countrCode) in
            self.btnCounty.setTitle(countrCode, for: .normal)
            
        }
    }
    
    @IBAction func actionPost(_ sender: Any) {
        if  PostViewModel.CheckValdations(forVc: self){
            
        }
    }
    @IBAction func actionShowCategories(_ sender: Any) {
        PostViewModel.openCategoryPicker(fromViewController: self, selectedCategories: arrSelectedCategories) { (categories) in
            if categories.count == 0{
                self.arrSelectedCategories.removeAll()
                self.txtCategories.text = ""
                return
            }
            self.arrSelectedCategories = categories
            self.txtCategories.text = categories.count == 1 ? "\(categories.count) Catgeory Selected" : "\(categories.count) Catgeories Selected"
        }
    }
    
}
extension PostViewController:UITextFieldDelegate,UITextViewDelegate{
    //MARK:-  text field delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= 3 && textField.tag <= 9 && textField.tag != 4{
            self.checkForTextFieldType(type: textField.tag)
            return false
        }
        if textField.tag == 1{
            self.lblTitleCharacLeft.isHidden = false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 8{
            
            textField.resignFirstResponder()
            return true
        }
        if let newTxtFld = self.view.viewWithTag(textField.tag + 1){
            newTxtFld.becomeFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField.tag != 1{
            return true
        }
        let numberOfChars = newText.count
        var charcCount = 30
        if textField.tag == 1{
            charcCount = 50
        }
        self.lblTitleCharacLeft.text = "\(50-newText.count) characters left"
        return numberOfChars < charcCount
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 && textField.text?.count == 0{
            self.lblTitleCharacLeft.isHidden = true
        }
    }
    //MARK:-  text View delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.lblDescriptionCharacterLeft.isHidden = false
    }
    func textViewDidChange(_ textView: UITextView) {
        
        var newFrame = PostViewModel.changeTextViewHt(textView: textView)
        let height = newFrame.size.height > 200 ? 200 : newFrame.size.height
        if textView == self.txtDescription{
            if txtDescription?.text == ""{
                newFrame.size.height = 52
                textView.frame = newFrame
                for constraint in self.txtDescription.constraints{
                    if constraint.identifier == KContrintDescriptionHt{
                        constraint.constant = 52
                    }
                }
                UIView.animate(withDuration: 0.5, animations: {
                    self.lblTitleDecsription.alpha = 0
                    for constraint in self.viewPostDescription.constraints{
                        if constraint.identifier == KContraintDescriptionTop{
                            constraint.constant = -4
                        }
                    }
                }) { (_) in
                    for constraint in self.viewPostDescription.constraints{
                        if constraint.identifier == KContraintDescriptionTop{
                            constraint.constant = 0
                        }
                    }
                }
                
            }else{
                for constraint in self.txtDescription.constraints{
                    if constraint.identifier == KContrintDescriptionHt{
                        constraint.constant = height
                    }
                }
                UIView.animate(withDuration: 0.5) {
                    self.lblTitleDecsription.alpha = 1
                    for constraint in self.viewPostDescription.constraints{
                        if constraint.identifier == KContraintDescriptionTop{
                            constraint.constant = -20
                        }
                    }
                }
            }
            
            
            
        }
        IQKeyboardManager.shared().reloadLayoutIfNeeded()
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let charcCount = 400
        if newText.count > 0{
            self.lblDescLine.backgroundColor = KAppThemeColor
        }
        else{
            self.lblDescLine.backgroundColor = .lightGray
            
        }
        self.lblDescriptionCharacterLeft.text = "\(400-newText.count) characters left"
        return numberOfChars < charcCount
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.lblDescLine.backgroundColor = .lightGray
        if textView.tag == 2 && textView.text?.count == 0{
            self.lblDescriptionCharacterLeft.isHidden = true
        }
    }
}

