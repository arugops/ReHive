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
        addresses      = AddressData.init(addrLine1:         rawAddress.data?.line_1        ?? "none",
                                          addrLine2:         rawAddress.data?.line_2        ?? "none",
                                          addrCity:          rawAddress.data?.city          ?? "none",
                                          addrStateProvince: rawAddress.data?.state_province ?? "none",
                                          addrCountry:       rawAddress.data?.country       ?? "none",
                                          addrPostCode:      rawAddress.data?.postal_code   ?? "none",
                                          addrStatus:        rawAddress.data?.status        ?? "none")
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

// User documents
struct RawUserDocs : Codable {
    let status      : String         // "success",
//    let data        : []
    let count       : Int
    let next        : String
    let previous    : String
    let results     : [RawUserDocsData]
}

struct RawUserDocsData : Codable {
    let id                  : Int
    let file                : String
    let document_category   : String
    let document_type       : String
    let metadata            : String?
    let status              : String?
    let note                : String?
}

public struct UserDocuments : Codable {
    public var status       : String?
    public var documents    : [UserDoc?]
    
    public struct UserDoc : Codable {
        public var id           : Int?
        public var file         : String?
        public var docCategory  : String?
        public var docType      : String?
        public var metadata     : String?
        public var status       : String?
        public var note         : String?
        //  public init() {}  // Can't use a public init since it interferes with the decode / encode initializer
        //  I use the newEmptyAccount() as my own initialiser
    }
    
    public init(from decoder: Decoder) throws {
        let rawDocumentsList = try RawUserDocs(from: decoder)
        status    = rawDocumentsList.status
        documents = []
        for document in rawDocumentsList.results {
            // print("account : \(account)")
            var doc = UserDoc()
            doc.id          = document.id
            doc.docCategory = document.document_category
            doc.docType     = document.document_type
            doc.metadata    = document.metadata
            doc.status      = document.status
            doc.note        = document.note
            documents.append(doc)
        }
    }
}

extension UserDocuments {
    public static func newDocument() -> UserDocuments.UserDoc {
        var newDocument = UserDoc()
        newDocument.id          = 0
        newDocument.docCategory = ""
        newDocument.docType     = ""
        newDocument.metadata    = ""
        newDocument.status      = ""
        newDocument.note        = ""
        return newDocument
    }
    
    public static func userDocsCall(_ account  : UserDocuments.UserDoc?,
                                      action   : RehiveCall,
                                      completionHandler: @escaping (UserDocuments?, Error?) -> Void) {
        let accountJSON:Data?
        let encoder = JSONEncoder()
        do {
            var acct = newDocument()
            switch action.callType {
            case CallType.newUsrCryptoAcc :
                accountJSON = try encoder.encode(acct)
            case CallType.getUsrCryptoAcc, CallType.delUsrCryptoAcc :
                acct.id = account?.id
                accountJSON = try encoder.encode(acct)
            case CallType.setUsrCryptoAcc :
                accountJSON = try encoder.encode(account)
            case CallType.listUsrCryptoAcc :
                accountJSON = nil
            default :
                return
            }
        } catch {
            completionHandler(nil, error)
            return
        }
        
        if let urlRequest = getURL(call: action, httpBody: accountJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(UserDocuments.self, from: data!)
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

// User email or mobile accounts
struct RawUsereMail : Codable {
    let status  : String         // "success",
    let data    : [RaweMailData]
}

struct RawUserMobile : Codable {
    let status  : String         // "success",
    let data    : [RawMobileData]
}

struct RaweMailData : Codable {
    let id          : Int
    let email       : String
    let primary     : String
    let verified    : String
}

struct RawMobileData : Codable {
    let id          : Int
    let number      : String
    let primary     : String
    let verified    : String
}

public struct UsereMailData : Codable {
    public var status       : String?
    public var details      : [UsereMail?]
    
    public struct UsereMail : Codable {
        public var id           : Int?
        public var eMail        : String?
        public var primary      : String?
        public var verified     : String?
        //  public init() {}  // Can't use a public init since it interferes with the decode / encode initializer
        //  I use the newEmptyAccount() as my own initialiser
    }
    
    public init(from decoder: Decoder) throws {
        let rawusereMailList = try RawUsereMail(from: decoder)
        status   = rawusereMailList.status
        details  = []
        for detail in rawusereMailList.data {
            // print("account : \(account)")
            var det = UsereMail()
            det.id          = detail.id
            det.eMail       = detail.email
            det.primary     = detail.primary
            det.verified    = detail.verified
            details.append(det)
        }
    }
}

extension UsereMailData {
    public static func newUserDetail() -> UsereMailData.UsereMail {
        var newDetail = UsereMail()
        newDetail.id         = 0
        newDetail.eMail      = ""
        newDetail.primary    = ""
        newDetail.verified   = ""
        return newDetail
    }
    
    public static func updateeMailCall(_ account  : UsereMailData.UsereMail?,
                                           action   : RehiveCall,
                                           completionHandler: @escaping (UsereMailData?, Error?) -> Void) {
        let accountJSON:Data?
        let encoder = JSONEncoder()
        do {
            var acct = newUserDetail()
            switch action.callType {
            case CallType.newUsreMail :
                accountJSON = try encoder.encode(acct)
            case CallType.getUsreMail, CallType.delUsreMail :
                acct.id = account?.id
                accountJSON = try encoder.encode(acct)
            case CallType.setUsreMail :
                accountJSON = try encoder.encode(account)
            case CallType.listUsreMail :
                accountJSON = nil
            default :
                return
            }
        } catch {
            completionHandler(nil, error)
            return
        }
        
        if let urlRequest = getURL(call: action, httpBody: accountJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(UsereMailData.self, from: data!)
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

public struct UserMobileData : Codable {
    public var status       : String?
    public var details      : [UserMobile?]
    
    public struct UserMobile : Codable {
        public var id           : Int?
        public var number       : String?
        public var primary      : String?
        public var verified     : String?
        //  public init() {}  // Can't use a public init since it interferes with the decode / encode initializer
        //  I use the newEmptyAccount() as my own initialiser
    }
    
    public init(from decoder: Decoder) throws {
        let rawMobileList = try RawUserMobile(from: decoder)
        status   = rawMobileList.status
        details  = []
        for detail in rawMobileList.data {
            // print("account : \(account)")
            var det = UserMobile()
            det.id          = detail.id
            det.number      = detail.number
            det.primary     = detail.primary
            det.verified    = detail.verified
            details.append(det)
        }
    }
}

extension UserMobileData {
    public static func newUserDetail() -> UserMobileData.UserMobile {
        var newDetail = UserMobile()
        newDetail.id         = 0
        newDetail.number     = ""
        newDetail.primary    = ""
        newDetail.verified   = ""
        return newDetail
    }
    
    public static func updateMobileCall(_ account  : UserMobileData.UserMobile,
                                         action   : RehiveCall,
                                         completionHandler: @escaping (UserMobileData?, Error?) -> Void) {
        let accountJSON:Data?
        let encoder = JSONEncoder()
        do {
            var acct = newUserDetail()
            switch action.callType {
            case CallType.newUsreMail :
                accountJSON = try encoder.encode(acct)
            case CallType.getUsreMail, CallType.delUsreMail :
                acct.id = account.id
                accountJSON = try encoder.encode(acct)
            case CallType.setUsreMail :
                accountJSON = try encoder.encode(account)
            case CallType.listUsreMail :
                accountJSON = nil
            default :
                return
            }
        } catch {
            completionHandler(nil, error)
            return
        }
        
        if let urlRequest = getURL(call: action, httpBody: accountJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(UserMobileData.self, from: data!)
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

