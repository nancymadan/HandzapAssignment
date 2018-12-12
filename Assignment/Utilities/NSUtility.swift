//
//  NSUtility.swift
//  Brezaa
//
//  Created by Deepak Bhagat on 5/11/17.
//  Copyright © 2017 Applify. All rights reserved.
//

import UIKit
import Foundation
import Photos
let debubPrintLog:Int = 1

class NSUtility: NSObject {
    
    
    /**
     - shared : This function is used to create a singleton object for NSUtility
     */
    class func shared()-> NSUtility{
        let nsutility = NSUtility()
        return nsutility
    }
    
   
    /**
     - findTextFieldAndHide : This function is used find the text views and text fields in view and hide them, call it when you press any button
     */
    
    
    func findTextFieldAndHide(view :UIView){
        for subView in view.subviews{
            if let txtV = subView as? UITextView{
                txtV.resignFirstResponder()
            }
            else if let textF = subView as? UITextField{
                textF.resignFirstResponder()
            }
            else if subView.subviews.count != 0{
                self.findTextFieldAndHide(view: subView)
            }
        }
    }
    /**
     - addTapGestureOnView : This function is used to add tap gesture to viewController's view
     - handleTap : This function is used to handle tap gesture's tap on viewController's view
     */
    class func addTapGestureOnView(view:UIView,cancelTouchInView:Bool,viewController:UIViewController){
        
        let tapGstr = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap))
        tapGstr.cancelsTouchesInView = cancelTouchInView
        view.addGestureRecognizer(tapGstr)
    }
    @objc static func handleTap() {
        self.fetchCurrentViewController().view.endEditing(true)
    }
    
    /**
     - changeDateFormat : This function is used to change date format
     */
    class func changeDateFormat(date:Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone =  TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = .current
        formatter.dateFormat = "EEE dd MMM"
        
        return formatter.string(from:date) 
    }
    
    /**
     - showAlert : This function is used to show alert on viewController's view
     */
    class func showAlertWithTitle(title:String, message:String,controller:UIViewController) {
        
        let alertController = UIAlertController(title: title == "" ? nil : title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        controller.present(alertController, animated: true, completion: nil)
        
    }
   
    
    //MARK: - Check For Empty String
    /**
     - checkIfStringContainsText : This function is used to check if the string is empty or not
     */
    class func checkIfStringContainsText(_ string:String?) -> Bool
    {
        if let stringEmpty = string {
            let newString = stringEmpty.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if(newString.isEmpty){
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    
   
    
    
    
    
    
    // MARK: - Show DebubLogs Methods
    /**
     1.    set value 1 to debubPrintLog to Enable the debuging logs
     2.    set value 0 to debubPrintLog to Disable the debuging logs
     3.    debubPrintLog is a Global variable
     */
    
    class func DBlog(_ message:Any) {
        if debubPrintLog == 1{
            
            print(message)
            
            //  NSLog(String(describing:message), "")
        }
        else{
            
        }
    }
   
    
    /**
     checkTextFieldHasText - This funcation is used to check if text is empty
     */
    static func checkTextFieldHasText(txt : String) -> Bool {
        if txt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            return false
        }
        return true
    }
    /**
     - trimAllSpaces : This function is used to trim text for text fields.
     */
    static func trimAllSpaces(txtField:UITextField)->UITextField{
        txtField.text = txtField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        return txtField
    }
   
    
    
    
    
    
    
    /**
     fetchCurrentViewController - This funcation is used to fetch current view controller
     */
    static func fetchCurrentViewController()->UIViewController{
        let navCntrl = KAPPDELEGATE?.window?.rootViewController as? UINavigationController
        if navCntrl != nil{
            let currentVc = navCntrl?.viewControllers.last!
            return currentVc!
        }
        return (KAPPDELEGATE?.window?.rootViewController)!
    }
    
   
  
    
    
    
    //MARK: - Check camera gallery options
    /**
     - cameraGalleryOptionsForAddImage : This function is used to check weather we have the permission to open gallery or not
     -showNoAccessAlert : This funcation is used to show alert for settings
     */
    
    static func checkCameraPermissionsForCamera(camera:Bool,withSuccess :@escaping (_ success:Bool)->Void){
        if (camera) {
            let  status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if(status == .notDetermined) {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    if granted == true {
                        // User granted
                        withSuccess(true)
                    } else {
                        // User rejected
                        withSuccess(false)
                    }
                })
                
            } else if (status == .authorized) {
                
                withSuccess(true)
                
            } else if (status == .restricted) {
                
                self.showNoAccessAlert(camera: camera)
                withSuccess(false)
            } else if (status == .denied) {
                self.showNoAccessAlert(camera: camera)
                withSuccess(false)
            }
            else{
                withSuccess(false)
            }
        }
            
        else{
            let status = PHPhotoLibrary.authorizationStatus()
            
            if(status == .notDetermined) {
                // Request photo authorization
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized{
                        withSuccess(true)
                    }
                    else{
                        withSuccess(false)
                    }
                })
            } else if (status == .authorized) {
                withSuccess(true)
                
            } else if (status == .restricted) {
                
                self.showNoAccessAlert(camera: camera)
                withSuccess(false)
            } else if (status == .denied) {
                self.showNoAccessAlert(camera: camera)
                withSuccess(false)
            }
            else{
                withSuccess(false)
            }
        }
    }
    static func showNoAccessAlert (camera : Bool){
        var alert = UIAlertController()
        if camera{
            alert = UIAlertController.init(title: KErrorTitle, message: KErrorCameraPermission, preferredStyle: UIAlertController.Style.alert)
        }
        else{
            alert = UIAlertController.init(title:  KErrorTitle, message: KErrorPhotosPermission, preferredStyle: UIAlertController.Style.alert)
        }
        alert.addAction(UIAlertAction.init(title: "Settings", style: UIAlertAction.Style.default, handler: { (success) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
            }
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        let currentVc = self.fetchCurrentViewController()
        currentVc.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
}
