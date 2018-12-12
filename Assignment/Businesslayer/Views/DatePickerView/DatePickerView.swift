//
//  DatePickerView.swift
//  Assignment
//
//  Created by Dev on 12/12/18.
//  Copyright © 2018 Dev. All rights reserved.
//

import UIKit

class DatePickerView: UIView {
    var strDateHandler: ((String) -> Void)?
    
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    
    
    
    //MARK:- button actions 
    @IBAction func actionDone(_ sender: Any) {
        let date = self.myDatePicker.date
        // Callback
        if let callback = self.strDateHandler {
            callback (NSUtility.changeDateFormat(date: date))
            UIView.animate(withDuration: 0.2, animations: {
                self.viewPicker.transform = CGAffineTransform.init(translationX: 0, y: KScreenHeight)
            }) { (_) in
                self.removeFromSuperview()
            }
        }
    }
}
