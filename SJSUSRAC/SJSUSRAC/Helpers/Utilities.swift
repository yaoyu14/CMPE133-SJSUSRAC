//
//  Utilities.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/27/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    static func styleTextField(_ textfield:UITextField){
        // create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        bottomLine.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        //remove border of text field
        textfield.borderStyle = .none
        
        //add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    
    static func styleFilledButton(_ button:UIButton) {
        //filled rounded corner style
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6719968906, blue: 0.0961645629, alpha: 1)
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.black
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.black
    }
    
    static func differentStyleFilledButton (_ button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.3241341114, green: 0.4266013503, blue: 0.9863418937, alpha: 1)
        button.layer.cornerRadius = 15.0
        button.tintColor = UIColor.white
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let testing = NSPredicate(format: "Self Matches %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return testing.evaluate(with: password)
    }
}

