//
//  CountryListViewController.swift
//  Tul
//
//  Created by dev on 27/09/17.
//  Copyright © 2017 dev. All rights reserved.
//

import UIKit


//protocol CountryListViewDelegate {
//    func didSelectCountry(country:NSDictionary)
//}

class CountryListViewController: UIViewController {
    let strAtr = NSMutableString()
    var strHandler: (String)->Void = {_ in }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    var dataRows: NSMutableArray = []
    var tempArray: NSArray = []
    
    //MARK:- override funcations
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        txtSearch.attributedPlaceholder = NSAttributedString.init(string: "Search Country", attributes: [.foregroundColor:UIColor.darkGray])
        let dataSource = CountryListDataSource()
        dataRows = NSMutableArray.init(array: dataSource.countries())
        tempArray = NSArray.init(array: dataRows)
        tableView.reloadData()
        
        let tap=UITapGestureRecognizer.init(target: self, action: #selector(self.tapHandler))
        tap.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func tapHandler() {
        self.view.endEditing(true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- button actions
    @IBAction func actionback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension CountryListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataRows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CountryCell
        if cell == nil {
            cell = CountryCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        //    NSLog(@"%@",[[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryName]);
        cell?.textLabel?.text = (dataRows[indexPath.row] as AnyObject).value(forKey: KCountryName) as? String
        cell?.textLabel?.font = Fonts.FontHelvetica(size: 14).fontsForApp
        cell?.detailTextLabel?.text = (dataRows[indexPath.row] as AnyObject).value(forKey: KCountryCode) as? String
        cell?.detailTextLabel?.font = Fonts.FontHelvetica(size: 14).fontsForApp
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.strHandler((dataRows[indexPath.row] as! NSDictionary).value(forKey: KCountryCode) as! String)
        dismiss(animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let newRow = self.index(forFirstChar: title, inArray: dataRows as! [[AnyHashable : Any]])
        
        let newIndexPath = IndexPath(row: newRow, section: 0)
        tableView.scrollToRow(at: newIndexPath, at: .top, animated: false)
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "Y", "Z"]
    }
    
    
    func index(forFirstChar character: String, inArray array: [[AnyHashable: Any]]) -> Int {
        var count: Int = 0
        for str in array {
            let name = str[KCountryName] as! String
            if name.hasPrefix(character) {
                return count
            }
            count += 1
        }
        return 0
    }
}

extension CountryListViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            if (strAtr.length>0) {
                strAtr.deleteCharacters(in: NSMakeRange(strAtr.length-1, 1))
            }
        }
        else{
            strAtr.append(string)
        }
        
        if (strAtr.length) > 0 {
            let options: String.CompareOptions = [.anchored,.caseInsensitive]
            dataRows.removeAllObjects()
            for i in 0..<tempArray.count {
                let aData = tempArray[i] as! NSDictionary
                let prefixRange: NSRange = (aData[KCountryName] as! NSString).range(of: strAtr as String, options: options)
                if prefixRange.location == 0 && prefixRange.length > 0 {
                    dataRows.add(aData)
                }
                else {
                    let prefixRange: NSRange = (aData[KCountryCode] as! NSString).range(of: strAtr as String, options: options)
                    if (prefixRange.location == 0 && prefixRange.length > 0) {
                        dataRows.add(aData)
                    }
                }
            }
        }else{
            dataRows.removeAllObjects()
            dataRows.addObjects(from: tempArray as! [Any])
        }
        self.tableView.reloadData()
        
        return true
    }
}

extension String {
    func rangeToIndex(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}

class CountryCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .none
        self.selectionStyle = .none
    }
}

class CountryListDataSource: NSObject {
    
    var countriesList = NSArray()
    
    override init() {
        super.init()
        
        parseJSON()
        
    }
    func parseJSON(){
        let data = NSData.init(contentsOfFile: Bundle.main.path(forResource: "countries", ofType: "json")!)
        let localError: Error? = nil
        let parsedObject = try? JSONSerialization.jsonObject(with: data! as Data, options: [])
        if localError != nil {
            //        NSLog(@"%@", [localError userInfo]);
        }
        else {
            
        }
        countriesList = parsedObject as! NSArray
    }
    
    func countries()->NSArray{
        return countriesList
    }
}
