//
//  ConstantData.swift
//  Assignment
//
//  Created by Dev on 12/12/18.
//  Copyright © 2018 Dev. All rights reserved.
//

import UIKit


let KArrRateTypes = ["No Preference","Fixed budget","Hourly Rate"]

let KArrPaymentMothodsTypes = ["No Preference","E-Payment","Cash"]
let KArrJoinTypes = ["No Preference","Same Day Job","Multi Days Job","Recurring Job"]

enum EnumOptionTypeStatus:Int{
    
    typealias RawValue = Int
    
    case Rate=0,Payment,JoinTerm
    
}
