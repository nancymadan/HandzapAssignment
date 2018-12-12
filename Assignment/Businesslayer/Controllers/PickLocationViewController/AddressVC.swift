//
//  AddressVC.swift
//  Tul
//
//  Created by Designer on 9/29/17.
//  Copyright © 2017 Designer. All rights reserved.
//

import UIKit
import GooglePlacePicker
import GoogleMaps
import GooglePlaces
import CoreLocation
import IQKeyboardManager



class AddressVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    //MARK:- Properties
    var selectedLat : CGFloat?
    var selectedLng : CGFloat?
    
    var strLocationHandler: ((String) -> Void)?
    var nameLabel: String!
    var addressLabel: String!
    var locationManager = CLLocationManager()
    var location = String()
    var arrLocation = [LocationModal]()
    
    
    @IBOutlet weak var textSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCurrentAddressOutlet: UIButton!
    @IBOutlet var contraintsTableBtm: NSLayoutConstraint!
    
    
    
    //MARK:- Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        setup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate=self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate=nil
    }
    
    //MARK:- gesture delegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
    
    //MARK:- Setup
    func setup(){
        // self.navigationController?.interactivePopGestureRecognizer?.delegate=self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:Notification.Name.UIKeyboardWillShow, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:  Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.textSearch.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.textSearch.delegate = self
        self.tableView.isHidden = false
        self.btnCurrentAddressOutlet.setTitle("Location", for: .normal)
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    //MARK:- Button Action
    
    
    @IBAction func btnCancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- Button Action
    @IBAction func btnSetLocationOnMapPressed(_ sender: UIButton) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "AddressOnMapVC") as! AddressOnMapVC
        myVC.strLocationHandler = {
            (location) -> Void in
            if let callback = self.strLocationHandler {
                callback (location)
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func btnCurrentLocationPressed(_ sender: UIButton) {
        
        let address = btnCurrentAddressOutlet.title(for: .normal)
        if address != "" && address != "Location" && selectedLat != nil && selectedLng != nil{
            // Callback
            if let callback = self.strLocationHandler {
                callback (address!)
            }
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func btnCrossPressed(_ sender: UIButton) {
        if textSearch.text != "" {
            textSearch.text = ""
        }
    }
    
    //MARK:- Table view data sources
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrLocation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
        let modalL = arrLocation[indexPath.row]
        
        cell.lblAddress.text = modalL.locationText
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let modalL = arrLocation[indexPath.row]
        
        FetchLocation.placeIdApiToGetLatLng(placeId: modalL.locationPlaceId!) { (modalL1) in
            
            if modalL1 == nil{
                NSUtility.showAlertWithTitle(title: KErrorTitle, message: "Some issue fetchong location", controller: self)
                return
            }
            self.dismiss(animated: true, completion: nil)
            
            if let callback = self.strLocationHandler {
                callback (modalL.locationText!)
            }
            //   self.newDelegate?.delegateSelectAddress(text: modalL.locationText!, lat: (modalL1?.locationLat!)!, lng: (modalL1?.locationLng!)!)
            
        }
        
        
        
    }
    
    
    
    //MARK:- Text field delegate functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let backspaceValue: Int32 = -92
        if (isBackSpace == backspaceValue) && textField.text!.count > 1 {
            // let str: String = (textField.text)!
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            FetchLocation.placeAutocomplete(searchData: (newText),completion: { (arr) in
                // print(arr!)
                if arr?.count != 0 {
                    self.fetchLocation(arrLoc: arr!)
                }
            })
            
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            
        }
        else if string == "" && textField.text!.count == 1 {
            self.arrLocation = []
            self.tableView.reloadData()
        }
            
        else {
            // print(textField.text!)
            let serchString = (textField.text!).appending(string)
            FetchLocation.placeAutocomplete(searchData: serchString,completion: { (arr) in
                // print(arr!)
                if arr?.count != 0 {
                    self.fetchLocation(arrLoc: arr!)
                }
                
            })
            
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if textSearch.text != "" {
            
            self.btnCurrentAddressOutlet.setTitle(self.location, for: .normal)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK:- Location manager delegate function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        //  DispatchQueue.global(qos: .background).async {
        
        FetchLocation.fetchCountryAndCity(location: location, completion: { (string) in
            self.location = string
            DispatchQueue.main.async { () -> Void in
                self.btnCurrentAddressOutlet.setTitle(self.location, for: .normal)
                self.selectedLat = CGFloat(location.coordinate.latitude)
                self.selectedLng = CGFloat(location.coordinate.longitude)
            }
        }, Error: { (string) in
            self.locationManager.stopUpdatingLocation()
            self.selectedLat = nil
            self.selectedLng = nil
            self.btnCurrentAddressOutlet.setTitle(string, for: .normal)
            NSUtility.showAlertWithTitle(title: KErrorTitle, message: KErrorUnableToFetchLocation, controller: self)
        } )
        
        // }
    }
    
    
    
    func fetchLocation(arrLoc: [LocationModal]){
        self.arrLocation = []
        for loc in arrLoc {
            self.arrLocation.append(loc)
        }
        self.tableView.reloadData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.5, animations: {
                self.contraintsTableBtm.constant = keyboardSize.height
                self.view.updateConstraintsIfNeeded()
            }, completion: { (success) in
                
            })
        }
    }
    
    //MARK: Keyboard will hide
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.contraintsTableBtm.constant = 0
    }
    
    
}

class AddressCell: UITableViewCell {
    
    
    @IBOutlet weak var lblAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class LocationModal : NSObject{
    var locationText : String?
    var locationPlaceId : String?
    var locationLat : CGFloat?
    var locationLng : CGFloat?
}

