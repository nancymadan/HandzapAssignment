//
//  AddressOnMapVC.swift
//  Tul
//
//  Created by Designer on 10/3/17.
//  Copyright © 2017 Designer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import IQKeyboardManager


class AddressOnMapVC: UIViewController, UITableViewDelegate, UITableViewDataSource ,UIGestureRecognizerDelegate{
    var selectedLat : CGFloat?
    var selectedLng : CGFloat?
    //MARK:- Properties
    var tap : UITapGestureRecognizer?
    
    let locationManager = CLLocationManager()
    var isMarkerAtCurrentLoc = false
    var timerScroll = Timer()
    var arrLocation = [LocationModal]()
    var strLocationHandler: ((String) -> Void)?
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet var contraintsTableBtm: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var btnDoneOutlet: UIButton!
    @IBOutlet weak var textViewSearchLocation: IQTextView!
    @IBOutlet weak var btnCrossOutlet: UIButton!
    //MARK:- Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        self.tapGesture()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate=self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate=nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.didReceiveMemoryWarning()
        
        self.transitionAction()
        //textViewSearchLocation.updateConstraintsIfNeeded()
        //textViewSearchLocation.sizeToFit()
        //textViewSearchLocation.frame.size.height = 56
        //        textViewSearchLocation.translatesAutoresizingMaskIntoConstraints = true
        
    }
    
    //MARK:- gesture delegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
    
    //MARK:- Setup
    func setUp(){
        // self.navigationController?.interactivePopGestureRecognizer?.delegate=self
        
        self.addMap()
        self.setMyLocation()
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        textViewSearchLocation.textContainer.maximumNumberOfLines = 2
        self.textViewSearchLocation.textContainer.lineBreakMode = .byWordWrapping
        mapView.delegate = self
    }
    
    //MARK:- Button Actions
    @IBAction func btnCancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnDonePressed(_ sender: UIButton) {
        if textViewSearchLocation.text != ""  && textViewSearchLocation.text != "Loading..."  && selectedLat != nil && selectedLng != nil{
            if let callback = self.strLocationHandler {
                self.dismiss(animated: true, completion: nil)
                
                callback (self.textViewSearchLocation.text)
            }
            
        }
    }
    
    @IBAction func btnCrossPressed(_ sender: UIButton) {
        self.arrLocation = []
        self.tableView.reloadData()
        self.openTableViewMenu()
        if textViewSearchLocation.text != ""{
            textViewSearchLocation.text = ""
            selectedLat = nil
            selectedLng = nil
            self.btnCross.isHidden = true
        }
        
        textViewSearchLocation.becomeFirstResponder()
    }
    @IBAction func actionNoLocation(_ sender: Any) {
        self.textViewSearchLocation.text = ""
        self.closeTableViewMenu()
        self.textViewSearchLocation.resignFirstResponder()
        
        if textViewSearchLocation.text == "" {
            //            textViewSearchLocation.text = strLastText
            //            if strLastText == ""{
            var destinationLocation = CLLocation()
            destinationLocation = CLLocation(latitude: mapView.camera.target.latitude,  longitude: mapView.camera.target.longitude)
            self.textViewSearchLocation.text = "Loading..."
            
            // DispatchQueue.global(qos: .background).async {
            FetchLocation.fetchCountryAndCity(location: destinationLocation, completion: { (string) in
                let location = string
                DispatchQueue.main.async { () -> Void in
                    
                    self.textViewSearchLocation.text = location
                    self.selectedLat = CGFloat(self.mapView.camera.target.latitude)
                    self.selectedLng = CGFloat(self.mapView.camera.target.longitude)
                    
                }
            }, Error: { (string) in
                
                self.selectedLat = nil
                self.selectedLng = nil
                self.textViewSearchLocation.text = string
                NSUtility.showAlertWithTitle(title: KErrorTitle, message: string, controller: self)
            })
            //}
            //}
        }
    }
    
    //MARK:- Add map
    func addMap(){
        if let styleURL = Bundle.main.url(forResource: "Style", withExtension: "json") {
            let  style = try? GMSMapStyle.init(contentsOfFileURL: styleURL)
            mapView.mapStyle = style
            
        } else {
            NSLog("Unable to find style.json")
        }
        
        mapView.isMyLocationEnabled=false
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    func setMyLocation(){
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            } else {
                
                // Fallback on earlier versions
            }
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    //MARK:- helper funcations
    func openTableViewMenu(){
        if arrLocation.count > 0 {
            self.tableView.isHidden=false
            UIView.animate(withDuration: 0.3){
                self.tableView.transform = CGAffineTransform.identity
            }
        }
        
    }
    func transitionAction(){
        self.tableView.transform = CGAffineTransform.init(translationX: 0, y: self.tableView.frame.size.height)
    }
    
    
    func closeTableViewMenu(){
        self.contraintsTableBtm.constant = 0
        UIView.animate(withDuration: 0.3){
            self.tableView.transform = CGAffineTransform.init(translationX: 0, y: KScreenHeight)
        }
    }
    
    
    
    //MARK:- Table view data sources
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrLocation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapAddressCell", for: indexPath) as! MapAddressCell
        let modalL = arrLocation[indexPath.row]
        cell.lblAddress.text = modalL.locationText
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.dismissKeyboard()
        let modalL = arrLocation[indexPath.row]
        self.textViewSearchLocation.text = modalL.locationText
        if self.textViewSearchLocation.text != ""  || self.textViewSearchLocation.text != "Loading..."
        {
            
            FetchLocation.placeIdApiToGetLatLng(placeId: modalL.locationPlaceId!) { (modalL1) in
                if modalL1 == nil{
                    NSUtility.showAlertWithTitle(title: KErrorTitle, message: "Some issue getting location's information", controller: self)
                    return
                }
                self.closeTableViewMenu()
                if let callback = self.strLocationHandler {
                    callback (self.textViewSearchLocation.text)
                    
                }
                
            }
        }
    }
    
    func fetchLocation(arrLoc: [LocationModal]){
        self.arrLocation = []
        for loc in arrLoc {
            self.arrLocation.append(loc)
        }
        if self.arrLocation.count == 0 {
            self.viewHeader.isHidden = false
            self.viewHeader.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 48)
            
        }
        else{
            self.viewHeader.isHidden = true
            self.viewHeader.frame = CGRect.zero
        }
        self.tableView.tableHeaderView = self.viewHeader
        self.tableView.reloadData()
    }
    
    
    
}

extension AddressOnMapVC: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //MARK:-Location Manager delegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last
        
        if isMarkerAtCurrentLoc == false {
            
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: mapView.camera.zoom)
            
            self.mapView.animate(to: camera)
            
            self.isMarkerAtCurrentLoc = true
        }
        
        
        
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("did fail update")
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL.init(string:UIApplication.openSettingsURLString)!)
            }
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
            }
        }
        else{
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK:- GMsMap view delegate
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        // let centerCord = mapView.camera.target
        
        //        mapVie.marker.position = centerCord
        //        mapVie.marker.map = mapView
        if textViewSearchLocation.text == "" {
            textViewSearchLocation.resignFirstResponder()
        }
        
        
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: mapView.camera.zoom)
        
        self.mapView.animate(to: camera)
        
        return true
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        //mapVie.marker.position = position.target
        var destinationLocation = CLLocation()
        destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
        self.textViewSearchLocation.text = "Loading..."
        
        
        FetchLocation.fetchCountryAndCity(location: destinationLocation, completion: { (string) in
            let location = string
            DispatchQueue.main.async { () -> Void in
                
                self.textViewSearchLocation.text = location
                self.selectedLat = CGFloat(self.mapView.camera.target.latitude)
                self.selectedLng = CGFloat(self.mapView.camera.target.longitude)
            }
        }, Error: { (string) in
            
            self.selectedLat = nil
            self.selectedLng = nil
            self.textViewSearchLocation.text = string
            NSUtility.showAlertWithTitle(title: KErrorTitle, message: string, controller: self)
        })
        
    }
}

extension AddressOnMapVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        self.btnCross.isHidden = false
        
        if textView.text == "Loading..." {
            textView.text = ""
        }
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let backspaceValue: Int32 = -92
        if (isBackSpace == backspaceValue) && textView.text!.count > 1{
            print(textView.text!)
            let char = String(textView.text.dropLast())
            if char == ""{
                self.btnCross.isHidden = true
                
                return true
            }
            
            FetchLocation.placeAutocomplete(searchData: (char),completion: { (arr) in
                print(arr!)
                if char != "" && self.textViewSearchLocation.text != "" && self.textViewSearchLocation.text != "Loading..."{
                    self.openTableViewMenu()
                    self.arrLocation = []
                    if arr?.count != 0 {
                        self.fetchLocation(arrLoc: arr!)
                    }
                    else {
                        self.viewHeader.isHidden = false
                        self.viewHeader.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 48)
                        self.tableView.tableHeaderView = self.viewHeader
                    }
                }
                
            })
            
            print(text)
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            
        }
            
        else if text == "" && textView.text!.count == 1 {
            self.closeTableViewMenu()
            self.arrLocation = []
            self.tableView.reloadData()
            
        }
            
        else {
            print(textView.text!)
            print(text)
            let serchString = (textView.text!).appending(text)
            if serchString == ""{
                self.btnCross.isHidden = true
            }
            FetchLocation.placeAutocomplete(searchData: (serchString),completion: { (arr) in
                print(arr!)
                if serchString != "" && self.textViewSearchLocation.text != ""  && self.textViewSearchLocation.text != "Loading..."{
                    self.openTableViewMenu()
                    self.arrLocation = []
                    if arr?.count != 0 {
                        self.fetchLocation(arrLoc: arr!)
                    }
                    else{
                        self.viewHeader.isHidden = false
                        self.viewHeader.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 48)
                        self.tableView.tableHeaderView = self.viewHeader
                        self.tableView.reloadData()
                    }
                }
            })
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Loading..." {
            textView.text = ""
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //        if textView.text == "" {
        //          //  textView.text = strLastText
        //           // if strLastText == ""{
        //                var destinationLocation = CLLocation()
        //                destinationLocation = CLLocation(latitude: mapView.camera.target.latitude,  longitude: mapView.camera.target.longitude)
        //                self.textViewSearchLocation.text = "Loading..."
        //
        //                DispatchQueue.global(qos: .background).async {
        //                    FetchLocation.fetchCountryAndCity(location: destinationLocation, completion: { (string) in
        //                        let location = string
        //                        DispatchQueue.main.async { () -> Void in
        //
        //                            self.textViewSearchLocation.text = location
        //
        //                        }
        //                    })
        //
        //
        //                }
        //           // }
        //            }
        //
        return true
    }
    //MARK: tap gesture
    func tapGesture(){
        //       tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        //        tap?.cancelsTouchesInView = false
        //        view.addGestureRecognizer(tap!)
    }
    //MARK: Dismiss keyboard
    @objc func dismissKeyboard() {
        self.textViewSearchLocation.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func searchLocationForTextView(loc: String){
        
        
        FetchLocation.searchLocation(searchData: loc,completion: { (arr, str) in
            print(arr!)
            
            let lat = arr?.latitude
            let long = arr?.longitude
            let camera = GMSCameraPosition.camera(withLatitude: (lat)!, longitude: (long)!, zoom:  15)
            print(lat as Any)
            print(long!)
            self.mapView.animate(to: camera)
            
            
            
        })
    }
    
    
    
    
    
    
}
class MapAddressCell: UITableViewCell {
    
    
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



