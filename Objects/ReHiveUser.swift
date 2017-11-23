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

struct RawAddress : Codable {
    let status      : String? //"success",
    let data        : RawAddressData?
    
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

public struct Address : Codable {
    public var status       : String?
    public var addresses    = AddressData()
    
    public struct AddressData  : Codable {
        public var addrLine1        : String? // Credit
        public var addrLine2        : String?
        public var addrCity         : String?
        public var addrStateProvince: String?
        public var addrCountry      : String?
        public var addrPostCode     : String?
        public var addrStatus       : String?
    }
    
    public init(from decoder: Decoder) throws {
        let rawAddress = try RawAddress(from: decoder)
        status         = rawAddress.status
        addresses      = AddressData.init(addrLine1:        rawAddress.data?.line_1 ?? "none",
                                          addrLine2:        rawAddress.data?.line_2 ?? "none",
                                          addrCity:         rawAddress.data?.city   ?? "none",
                                          addrStateProvince: rawAddress.data?.state_province  ?? "none",
                                          addrCountry:      rawAddress.data?.country  ?? "none",
                                          addrPostCode:     rawAddress.data?.postal_code  ?? "none",
                                          addrStatus:       rawAddress.data?.status  ?? "none")
    }
}

extension Address {
    public static func getAddress( completionHandler: @escaping (Address?, Error?) -> Void) {
        if let urlRequest = getURL(call: getUsrAddress, httpBody: nil) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                //  print("response \(response)")
                //  print("data \(data)")
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(Address.self, from: data!)
                    if reply.status == "error" {
                        completionHandler(nil, error!)
                    } else {
                        completionHandler(reply, nil)
                    }
                } catch {
                    completionHandler(nil, error)
                }
            })
            task.resume()
        }
    }
}

