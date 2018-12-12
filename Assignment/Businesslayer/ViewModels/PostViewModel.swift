//
//  PostViewModel.swift
//  Assignment
//
//  Created by Dev on 11/12/18.
//  Copyright © 2018 Dev. All rights reserved.
//

import UIKit

class PostViewModel: NSObject {
      //MARK:- picker for location
    static func openLocationPicker(fromViewController parentController:UIViewController, success:@escaping (String)->Void){
        let myVC = parentController.storyboard?.instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        myVC.strLocationHandler = {
            (str) -> Void in
            success(str)
        }
        parentController.present(myVC, animated: true, completion: nil)
    }
    
      //MARK:- picker for post category
    static func openCategoryPicker(fromViewController parentController:UIViewController,selectedCategories:[Int], success:@escaping ([Int])->Void){
        let myVC = parentController.storyboard?.instantiateViewController(withIdentifier: "PostCategoriesViewController") as! PostCategoriesViewController
        myVC.arrIndexSelect = selectedCategories
        myVC.strCategoriesHandler = {
            (catogories) -> Void in
            success(catogories)
        }
        parentController.present(myVC, animated: true, completion: nil)
    }
      //MARK:- picker for country code
    static func openCountryPicker(fromViewController parentController:UIViewController, success:@escaping (String)->Void){
        let vc = CountryListViewController.init(nibName: "CountryListViewController", bundle: nil)
        vc.strHandler = {
            (str) -> Void in
            success(str)
        }
        parentController.present(vc, animated: true, completion: nil)
    }
    
      //MARK:- picker for options
    static func pickOption(fromViewController parentController:UIViewController,forCategory type : Int, success:@escaping (String)->Void){
        let alertVc = UIAlertController.init(title: "Pick One", message: nil, preferredStyle: .actionSheet)
        var arrOptions : [String]? = nil
        switch type {
        case EnumOptionTypeStatus.Rate.rawValue:
            arrOptions = KArrRateTypes
            break
        case EnumOptionTypeStatus.Payment.rawValue:
            arrOptions = KArrPaymentMothodsTypes
            break
        case EnumOptionTypeStatus.JoinTerm.rawValue:
            arrOptions = KArrJoinTypes
            break
        default:
            break
        }
        for option in arrOptions ?? []{
            alertVc.addAction(UIAlertAction.init(title: option, style: .default, handler: { (_) in
                success(option)
            }))
        }
        alertVc.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        parentController.present(alertVc, animated: true, completion: nil)
    }
    
    
    //MARK:- check validations
    /**
     - check validations: This function is used to check validation for each entry before submiting the form to backend.
     */
    static func CheckValdations(forVc : PostViewController)-> Bool{
        if  !NSUtility.checkTextFieldHasText(txt: forVc.txtTitle.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorTitleEmpty, controller: forVc)
            return false
        }
            
        else  if !NSUtility.checkTextFieldHasText(txt: forVc.txtDescription.text!) {
            NSUtility.showAlertWithTitle(title:  KErrorTitle, message: KErrorDecsriptionEmpty, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtCategories.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorPostCategory, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtCategories.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorPostCategory, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtBudget.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorBudget, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.btnCounty.title(for: .normal) ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorCurrency, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtRate.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorRate, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtPaymentMethod.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorPaymentMethod, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtLocation.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorLocation, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtStartDate.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorStartDate, controller: forVc)
            return false
        }
        else if  !NSUtility.checkTextFieldHasText(txt: forVc.txtJoinTerms.text ?? ""){
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorJoinTerm, controller: forVc)
            return false
        }
        return true
    }
      //MARK:- update text view's ht
    static func changeTextViewHt(textView:UITextView)->CGRect{
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        let height = newFrame.size.height > 200 ? 200 : newFrame.size.height
        
        textView.isScrollEnabled = false
        
        newFrame.size.height = height
        
        textView.frame = newFrame
        return newFrame
        
    }
      //MARK:- date picker
    static func openDatePicker(fromViewController parentController:UIViewController, success:@escaping (String)->Void){
        let view = UIView.loadFromNibNamed("DatePickerView", bundle: nil) as! DatePickerView
        view.viewPicker.transform = CGAffineTransform.init(translationX: 0, y: KScreenHeight)
        view.strDateHandler = {
            (str) -> Void in
            success(str)
        }
        parentController.view.addSubview(view)
        UIView.animate(withDuration: 0.2) {
            view.viewPicker.transform = CGAffineTransform.identity
        }
    }
}

