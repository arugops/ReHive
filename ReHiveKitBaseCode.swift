//
//  reHiveKitBaseCode.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation
import UIKit

public let baseURL      = "https://www.rehive.com/api/3/"
public var hiveSession  = URLSession.shared
public var currentToken = ""
public var contentType  = "application/json"

public enum RequestType : String {
    case get    = "GET"
    case put    = "PUT"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
}

public enum CallType : String {
    case registerCompany            = "Register Company"
    case register                   = "Register"
    case login                      = "Login"
    case logout                     = "Logout"
    case logoutAll                  = "Logout All"
    case changePW                   = "Change Password"
    case resetPW                    = "Reset Password"
    case resetPWConfirm             = "Reset Password Confirm"
    case resendeMailVerification    = "Resend eMail Verification"
    case resendeMobileVerification  = "Resend Mobile Verification"
    case verifyeMail                = "Verify eMail"
    case verifyeMobile              = "Verify Mobile"
    case txnList                    = "List Transactions"
    case txnTotal                   = "Total Transactions"
    case txnDebit                   = "Create Debit"
    case txnCredit                  = "Create Credit"
    case txnTransfer                = "Create Transfer"
    case txnRetrieve                = "Retrieve Transactions"
    case getUsrProfile              = "Retrieve Profile"
    case setUsrProfile              = "Update Profile"
    case getUsrAddress              = "Retrieve Address"
    case setUsrAddress              = "Update Address"
    case listUsrBankAcc             = "Retrieve Bank account list"
    case newUsrBankAcc              = "Create Bank account"
    case getUsrBankAcc              = "Retrieve Bank account"
    case setUsrBankAcc              = "Update Bank account"
    case delUsrBankAcc              = "Delete Bank account"
    case listUsrCryptoAcc           = "Retrieve Crypto account list"
    case newUsrCryptoAcc            = "Create Crypto account"
    case getUsrCryptoAcc            = "Retrieve Crypto account"
    case setUsrCryptoAcc            = "Update Crypto account"
    case delUsrCryptoAcc            = "Delete Crypto account"
    case getUsrDocuments            = "User Documents List"
    case listUsreMail               = "Retrieve email list"
    case newUsreMail                = "Create email account"
    case getUsreMail                = "Retrieve email account"
    case setUsreMail                = "Update email account"
    case delUsreMail                = "Delete email account"
    case listUsrMobile              = "Retrieve Mobile list"
    case newUsrMobile               = "Create Mobile account"
    case getUsrMobile               = "Retrieve Mobile account"
    case setUsrMobile               = "Update Mobile account"
    case delUsrMobile               = "Delete Mobile account"
}

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

public struct RehiveCall {
    var callType    : CallType
    var requestType : RequestType
    var endPoint    : String
}

// Auth
public let registerCompany = RehiveCall(callType: CallType.register,       requestType: RequestType.post,  endPoint: baseURL + "auth/company/register/")
public let register        = RehiveCall(callType: CallType.register,       requestType: RequestType.post,  endPoint: baseURL + "auth/register/")
public let login           = RehiveCall(callType: CallType.login,          requestType: RequestType.post,  endPoint: baseURL + "auth/login/")
public let logout          = RehiveCall(callType: CallType.logout,         requestType: RequestType.post,  endPoint: baseURL + "auth/logout/")
public let logoutAll       = RehiveCall(callType: CallType.logoutAll,      requestType: RequestType.post,  endPoint: baseURL + "auth/logout/all/")
let changePassword  = RehiveCall(callType: CallType.changePW,       requestType: RequestType.post,  endPoint: baseURL + "auth/password/change/")
let resetPassword   = RehiveCall(callType: CallType.resetPW,        requestType: RequestType.post,  endPoint: baseURL + "auth/password/reset/")
let resetPWConfirm  = RehiveCall(callType: CallType.resetPWConfirm, requestType: RequestType.post,  endPoint: baseURL + "auth/password/reset/confirm/")
let resendeMailVerification     = RehiveCall(callType: CallType.resendeMailVerification,   requestType: RequestType.post,  endPoint: baseURL + "auth/email/verify/resend/")
let resendeMobileVerification   = RehiveCall(callType: CallType.resendeMobileVerification,   requestType: RequestType.post,  endPoint: baseURL + "auth/mobile/verify/resend/")
let emailVerify     = RehiveCall(callType: CallType.resetPW,     requestType: RequestType.post,  endPoint: baseURL + "auth/auth/email/verify/")
let mobileVerify    = RehiveCall(callType: CallType.resetPW,     requestType: RequestType.post,  endPoint: baseURL + "auth/auth/email/verify/")

// Transactions
let txnTotal        = RehiveCall(callType: CallType.txnTotal,       requestType: RequestType.get,   endPoint: baseURL + "transactions/totals/")
let txnList         = RehiveCall(callType: CallType.txnList,        requestType: RequestType.get,   endPoint: baseURL + "transactions/")
let txnDebit        = RehiveCall(callType: CallType.txnDebit,       requestType: RequestType.get,   endPoint: baseURL + "transactions/debit/")
let txnCredit       = RehiveCall(callType: CallType.txnCredit,      requestType: RequestType.post,  endPoint: baseURL + "transactions/credit/")
let txnTransfer     = RehiveCall(callType: CallType.txnCredit,      requestType: RequestType.post,  endPoint: baseURL + "transactions/transfer/")
let txnRetrieve     = RehiveCall(callType: CallType.txnRetrieve,    requestType: RequestType.get,   endPoint: baseURL + "transactions/{id}")

// User
let getUsrProfile   = RehiveCall(callType: CallType.getUsrProfile,  requestType: RequestType.get,   endPoint: baseURL + "user/")
let setUsrProfile   = RehiveCall(callType: CallType.setUsrProfile,  requestType: RequestType.patch, endPoint: baseURL + "user/")
let getUsrAddress   = RehiveCall(callType: CallType.getUsrAddress,  requestType: RequestType.get,   endPoint: baseURL + "user/address/")
let setUsrAddress   = RehiveCall(callType: CallType.setUsrAddress,  requestType: RequestType.patch, endPoint: baseURL + "user/address/")
public let listUsrBankAcc   = RehiveCall(callType: CallType.listUsrBankAcc,   requestType: RequestType.get,   endPoint: baseURL + "user/bank-accounts/")
public let newUsrBankAcc    = RehiveCall(callType: CallType.newUsrBankAcc,    requestType: RequestType.post,  endPoint: baseURL + "user/bank-accounts/")
public let getUsrBankAcc    = RehiveCall(callType: CallType.getUsrBankAcc,    requestType: RequestType.get,   endPoint: baseURL + "user/bank-accounts/{account_id}/")
public let setUsrBankAcc    = RehiveCall(callType: CallType.setUsrBankAcc,    requestType: RequestType.patch, endPoint: baseURL + "user/bank-accounts/{account_id}/")
public let delUsrBankAcc    = RehiveCall(callType: CallType.delUsrBankAcc,    requestType: RequestType.delete,endPoint: baseURL + "user/bank-accounts/{account_id}/")

public let listUsrCryptoAcc = RehiveCall(callType: CallType.listUsrCryptoAcc, requestType: RequestType.get,   endPoint: baseURL + "user/crypto-accounts/")
public let newUsrCryptoAcc  = RehiveCall(callType: CallType.newUsrCryptoAcc,  requestType: RequestType.post,  endPoint: baseURL + "user/crypto-accounts/")
public let getUsrCryptoAcc  = RehiveCall(callType: CallType.getUsrCryptoAcc,  requestType: RequestType.get,   endPoint: baseURL + "user/crypto-accounts/{account_id}/")
public let setUsrCryptoAcc  = RehiveCall(callType: CallType.setUsrCryptoAcc,  requestType: RequestType.patch, endPoint: baseURL + "user/crypto-accounts/{account_id}/")
public let delUsrCryptoAcc  = RehiveCall(callType: CallType.delUsrCryptoAcc,  requestType: RequestType.delete,endPoint: baseURL + "user/crypto-accounts/{account_id}/")

public let listUsreMail     = RehiveCall(callType: CallType.listUsreMail,     requestType: RequestType.get,   endPoint: baseURL + "user/emails/")
public let newUsreMail      = RehiveCall(callType: CallType.newUsreMail,      requestType: RequestType.post,  endPoint: baseURL + "user/emails/")
public let getUsreMail      = RehiveCall(callType: CallType.getUsreMail,      requestType: RequestType.get,   endPoint: baseURL + "user/emails/{id}/")
public let setUsreMail      = RehiveCall(callType: CallType.setUsreMail,      requestType: RequestType.patch, endPoint: baseURL + "user/emails/{id}/")
public let delUsreMail      = RehiveCall(callType: CallType.delUsreMail,      requestType: RequestType.delete,endPoint: baseURL + "user/emails/{id}/")

public let listUsrMobile    = RehiveCall(callType: CallType.listUsrMobile,    requestType: RequestType.get,   endPoint: baseURL + "user/mobiles/")
public let newUsrMobile     = RehiveCall(callType: CallType.newUsrMobile,     requestType: RequestType.post,  endPoint: baseURL + "user/mobiles/")
public let getUsrMobile     = RehiveCall(callType: CallType.getUsrMobile,     requestType: RequestType.get,   endPoint: baseURL + "user/mobiles/{id}/")
public let setUsrMobile     = RehiveCall(callType: CallType.setUsrMobile,     requestType: RequestType.patch, endPoint: baseURL + "user/mobiles/{id}/")
public let delUsrMobile     = RehiveCall(callType: CallType.delUsrMobile,     requestType: RequestType.delete,endPoint: baseURL + "user/mobiles/{id}/")

let getUsrDocuments = RehiveCall(callType: CallType.getUsrDocuments,  requestType: RequestType.get,   endPoint: baseURL + "user/documents/")

struct JSONError : Codable {
    let status  : String
    let message : String // "First error message, Second error message",
    //    struct ErrorData : Codable {
    //        let field_name1 : [String]        //"First error message."
    //        let field_name2 : [String]        //"Second error message."
    //    }
    //    let data : ErrorData
}

func getURL(call: RehiveCall, httpBody: Data?) -> URLRequest? {
    guard let url = URL(string: call.endPoint) else {
//        let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON1)
        return nil
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = call.requestType.rawValue
    if call.requestType == RequestType.post {
        urlRequest.httpBody = httpBody
    }
    if call.callType != CallType.login {
        let authorizationKey = "Token "+currentToken
        urlRequest.addValue(authorizationKey, forHTTPHeaderField: "Authorization")
    }
    urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
    return urlRequest
}

struct Currency : Codable {
    let description     : String
    let code            : String
    let symbol          : String
    let unit            : String
    let divisibility    : Int
}

struct ErrorAction {
    static let ErrorActionAdd       = NSLocalizedString("ErrorActionAdd",       comment:"Unable to add ")
    static let ErrorActionSend      = NSLocalizedString("ErrorActionSend",      comment:"Unable to send ")
    static let ErrorActionWrite     = NSLocalizedString("ErrorActionWrite",     comment:"Unable to write ")
    static let ErrorActionChange    = NSLocalizedString("ErrorActionChange",    comment:"Unable to change ")
    static let ErrorActionDelete    = NSLocalizedString("ErrorActionDelete",    comment:"Unable to delete ")
    static let ErrorActionFetch     = NSLocalizedString("ErrorActionFetch",     comment:"Unable to fetch ")
    static let ErrorActionUse       = NSLocalizedString("ErrorActionUse",       comment:"Unable to use ")
    static let ErrorActionLogin     = NSLocalizedString("ErrorActionLogin",     comment:"Unable to log in ")
    static let ErrorActionJSON1     = NSLocalizedString("ErrorActionJSON1",     comment:"Could not create URL")
    static let ErrorActionJSON2     = NSLocalizedString("ErrorActionJSON2",     comment:"did not receive data")
    static let ErrorActionJSON3     = NSLocalizedString("ErrorActionJSON3",     comment:"error trying to convert data to JSON")
}

struct ErrorEntity {
    static let ErrorEntityAudio     = NSLocalizedString("ErrorEntityAudio",     comment:" Audio ")
    static let ErrorEntityIAP       = NSLocalizedString("ErrorEntityIAP",       comment:" In App Purchase ")
    static let ErrorEntityCalendar  = NSLocalizedString("ErrorEntityCalendar",  comment:" Apple Calendar ")
    static let ErrorEntityContact   = NSLocalizedString("ErrorEntityContact",   comment:" Apple Contacts ")
    static let ErrorEntityProduct   = NSLocalizedString("ErrorEntityProduct",   comment:" Product ")
    static let ErrorEntityPrice     = NSLocalizedString("ErrorEntityPrice",     comment:" Price ")
    static let ErrorEntityVersion   = NSLocalizedString("ErrorEntityVersion",   comment:" Version ")
    static let ErrorEntityKeyChain  = NSLocalizedString("ErrorEntityKeyChain",  comment:" Key Chain ")
}

