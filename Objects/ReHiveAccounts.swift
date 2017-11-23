//
//  ReHiveAccounts.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation

//https://rehive.com/api/3/user/bank-accounts/
// User bank accounts
struct RawBankAccounts : Codable {
    let status  : String         // "success",
    let data    : [BankAccountData]
}

struct BankAccountData : Codable {
    let id          : Int       // "id": 1,
    let name        : String    //"Default",
    let number      : String    //"9999999999",
    let type        : String    //"Cheque",
    let bank_name   : String    //"Central Bank",
    let bank_code   : String    //"0000",
    let branch_code : String    //"0000",
    let swift       : String    //"",
    let iban        : String    //"",
    let bic         : String    //"",
    let code        : String    //"bank_account_VEM7k1y5hnuF",
    let status      : String    //"pending"
}

public struct BankAccountList : Codable {
    public var status       : String
    public var accounts     : [BankAccount]
    
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
        public var code         : String?
        public var status       : String?
    }
    
    public init(from decoder: Decoder) throws {
        let rawBankAccountsList = try RawBankAccounts(from: decoder)
        status       = rawBankAccountsList.status
        accounts = []
        for result in rawBankAccountsList.data {
            //            print("result : \(result)")
            let txn = BankAccount.init(id:          result.id ,
                                       name:        result.name,
                                       number:      result.number ,
                                       type:        result.type,
                                       bankName:    result.bank_name,
                                       bankCode:    result.bank_code,
                                       branchCode:  result.branch_code,
                                       swift:       result.swift,
                                       iban:        result.iban,
                                       code:        result.code,
                                       status:      result.status  )
            accounts.append(txn)
        }
    }
}

extension BankAccountList {
    public static func getBankAccountList( completionHandler: @escaping (BankAccountList?, Error?) -> Void) {
        if let urlRequest = getURL(call: listUsrBankAcc, httpBody: nil) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                //                print("response \(response)")
                //                print("data \(data)")
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(BankAccountList.self, from: data!)
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


