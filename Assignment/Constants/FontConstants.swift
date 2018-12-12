//
//  FontConstants.swift
//
//  Created by dev on 26/09/17.
//  Copyright © 2017 dev. All rights reserved.
//
import UIKit
enum Fonts {
   
    case FontHelvetica(size : Int)
    var fontsForApp : UIFont{
        switch self {
        
        case .FontHelvetica(let size):
            return  UIFont.init(name: "HelveticaNeue", size: CGFloat(size))!
       
        }
        
    }
    
    
}


