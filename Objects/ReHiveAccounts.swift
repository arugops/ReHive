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
    let data    : [BankData]
}

struct BankData : Codable {
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


/*
 enum CodingKeys : String, CodingKey {
 case bankID     = "id"
 case name
 case number
 case type
 case bankName   = "bank_name"
 case bankCode   = "bank_code"
 case branchCode = "branch_code"
 case swift
 case iban
 case bic
 case code
 case status
 }
*/
