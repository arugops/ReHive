//
//  ReHiveAccounts.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation

// User bank accounts
struct RawBankAccounts : Codable {
    let status  : String         // "success",
    let data    : [RawBankAccountData]
}

struct RawBankAccountData : Codable {
    let id          : Int       // "id": 1,
    let name        : String    //"Default",
    let number      : String    //"9999999999",
    let type        : String    //"Cheque",
    let bank_name   : String    //"Central Bank",
    let bank_code   : String    //"0000",
    let branch_code : String    //"0000",
    let swift       : String?   //"",
    let iban        : String?   //"",
    let bic         : String?   //"",
    let code        : String?   //"bank_account_VEM7k1y5hnuF",
    let status      : String    //"pending"
}

public struct BankAccounts : Codable {
    public var status       : String?
    public var accounts     : [BankAccount?]

    public struct BankAccount : Codable {
        public var id           : Int?
        public var name         : String?
        public var number       : String?
        public var type         : String?
        public var bankName     : String?
        public var bankCode     : String?
        public var branchCode   : String?
        public var swift        : String?
        public var iban         : String?
        public var bic          : String?
        public var code         : String?
        public var status       : String?
        //  public init() {}  // Can't use a public init since it interferes with the decode / encode initializer
        //  I use the newEmptyAccount() as my own initialiser
    }
    
    public init(from decoder: Decoder) throws {
        let rawBankAccountsList = try RawBankAccounts(from: decoder)
        status   = rawBankAccountsList.status
        accounts = []
        for account in rawBankAccountsList.data {
            // print("account : \(account)")
            var act = BankAccount()
            act.id          = account.id
            act.name        = account.name
            act.number      = account.number
            act.type        = account.type
            act.bankName    = account.bank_name
            act.bankCode    = account.bank_code
            act.branchCode  = account.branch_code
            act.swift       = account.swift
            act.iban        = account.iban
            act.bic         = account.bic
            act.code        = account.code
            act.status      = account.status
            accounts.append(act)
        }
    }
}

extension BankAccounts {
    public static func newEmptyAccount() -> BankAccounts.BankAccount {
        var newAcct = BankAccount()
        newAcct.id          = 0
        newAcct.name        = ""
        newAcct.type        = ""
        newAcct.number      = ""
        newAcct.bankName    = ""
        newAcct.branchCode  = ""
        return newAcct
    }
    
    public static func bankAccountCall(_ account  : BankAccounts.BankAccount?,
                                         action   : RehiveCall,
                                         completionHandler: @escaping (BankAccounts?, Error?) -> Void) {
        let accountJSON:Data?
        let encoder = JSONEncoder()
        do {
            var acct = newEmptyAccount()
            switch action.callType {
            case CallType.NewUsrBankAcc :
                accountJSON = try encoder.encode(acct)
            case CallType.GetUsrBankAcc, CallType.DelUsrBankAcc :
                acct.id = account?.id
                accountJSON = try encoder.encode(acct)
            case CallType.SetUsrBankAcc :
                accountJSON = try encoder.encode(account)
            case CallType.ListUsrBankAcc :
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
                    let reply = try decoder.decode(BankAccounts.self, from: data!)
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


