//
//  ReHiveCompany.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation


struct Company : Codable {
    struct Data : Codable {
        let identifier      : String?    // "rehive",
        let companyName     : String?    // "name": "Rehive",
        let description     : String?    // "Wallets for everyone.",
        let website         : URL?       // "http://www.rehive.com",
        let nationalities   : [String]
        let logo            : String?
        enum CodingKeys : String, CodingKey {
            case identifier
            case companyName = "name"
            case description
            case website
            case nationalities
            case logo
        }
    }
    
    let data    : Data
    let status  : String    // "success"
}
