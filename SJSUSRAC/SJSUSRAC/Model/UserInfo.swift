//
//  UserInfo.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 11/25/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import Foundation

class UserInfo {
    var uid: String
    var reservedTimes = [String]()
    
    init (uid: String, reservedtimes: [String]) {
        self.uid = uid
        self.reservedTimes = reservedTimes
    }
    
}
