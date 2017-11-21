//
//  ReHiveUser.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation

struct RawUser : Codable {
    let identifier   : String?       //00000000-0000-0000-0000-000000000000,
    let first_name   : String?       //Joe,
    let last_name    : String?
    let email        : String?       //joe@rehive.com,
    let username     : String?
    let id_number    : String?
    let birth_date   : Date?
    let profile      : String?
    let currency     : UserCurrency?
    let company      : String?
    let language     : String?
    let nationality  : String?       // ZA
    let metadata     : Metadata?        //Metadata?       // {},
    let mobile_number: String?       //+00000000000,
    let timezone     : String?
    let verified     : Bool?

    struct UserCurrency: Codable {
        let currency    : String?
    }
}

public struct User : Codable {
    public var identifier  : String  = ""
    public var firstName   : String  = ""
    public var lastName    : String  = ""
    public var email       : String  = ""
    public var userName    : String  = ""
    public var idNumber    : String  = ""
    public var birthDate   : Date?   = nil
    public var profile     : String  = ""
    public var currency    : String  = ""
    public var company     : String  = ""
    public var language    : String  = ""
    public var nationality : String  = ""
    public var mobileNumber: String  = ""
    public var timezone    : String  = ""
    public var verified    : Bool    = false
}

struct RawPartUser : Codable {
    let identifier  : String?       //00000000-0000-0000-0000-000000000000,
    let first_name  : String?       //Joe,
    let last_name   : String?
    let email       : String?       //joe@rehive.com,
    let username    : String?
    let mobile_number: String?       //+00000000000,
    let profile     : String?
}

struct Address : Codable {
    let status      : String //"success",
    let data        : RawAddressData
    
}
struct RawAddressData : Codable {
    let line_1      : String    //"1 Main Street",
    let line_2      : String    //"East City",
    let city        : String    //"Cape Town",
    let state_province : String //"Western Cape",
    let country     : String    //"ZA",
    let postal_code : String    //"8001",
    let status      : String    // "pending"
}

/*
 enum CodingKeys : String, CodingKey {
 case identifier
 case firstName = "first_name"
 case lastName  = "last_name"
 case email
 case username
 case idNumber  = "id_number"
 case birthDate = "birth_date"
 case profile
 //        case currency
 case company
 case language
 //        case nationality
 case metadata
 case mobileNumber = "mobile_number"
 case timezone
 case verified
 }
*/
