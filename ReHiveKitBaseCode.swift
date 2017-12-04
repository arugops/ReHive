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
    case RegisterCompany            = "Register Company"
    case Register                   = "Register"
    case Login                      = "Login"
    case Logout                     = "Logout"
    case LogoutAll                  = "Logout All"
    case ChangePW                   = "Change Password"
    case ResetPW                    = "Reset Password"
    case ResetPWConfirm             = "Reset Password Confirm"
    case ResendeMailVerification    = "Resend eMail Verification"
    case ResendeMobileVerification  = "Resend Mobile Verification"
    case VerifyeMail                = "Verify eMail"
    case VerifyeMobile              = "Verify Mobile"
    case TxnList                    = "List Transactions"
    case TxnTotal                   = "Total Transactions"
    case TxnDebit                   = "Create Debit"
    case TxnCredit                  = "Create Credit"
    case TxnTransfer                = "Create Transfer"
    case TxnRetrieve                = "Retrieve Transactions"
    case GetUsrProfile              = "Retrieve Profile"
    case SetUsrProfile              = "Update Profile"
    case GetUsrAddress              = "Retrieve Address"
    case SetUsrAddress              = "Update Address"
    case ListUsrBankAcc             = "Retrieve Bank account list"
    case NewUsrBankAcc              = "Create Bank account"
    case GetUsrBankAcc              = "Retrieve Bank account"
    case SetUsrBankAcc              = "Update Bank account"
    case DelUsrBankAcc              = "Delete Bank account"
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
public let registerCompany = RehiveCall(callType: CallType.Register,       requestType: RequestType.post,  endPoint: baseURL + "auth/company/register/")
public let register        = RehiveCall(callType: CallType.Register,       requestType: RequestType.post,  endPoint: baseURL + "auth/register/")
public let login           = RehiveCall(callType: CallType.Login,          requestType: RequestType.post,  endPoint: baseURL + "auth/login/")
public let logout          = RehiveCall(callType: CallType.Logout,         requestType: RequestType.post,  endPoint: baseURL + "auth/logout/")
public let logoutAll       = RehiveCall(callType: CallType.LogoutAll,      requestType: RequestType.post,  endPoint: baseURL + "auth/logout/all/")
let changePassword  = RehiveCall(callType: CallType.ChangePW,       requestType: RequestType.post,  endPoint: baseURL + "auth/password/change/")
let resetPassword   = RehiveCall(callType: CallType.ResetPW,        requestType: RequestType.post,  endPoint: baseURL + "auth/password/reset/")
let resetPWConfirm  = RehiveCall(callType: CallType.ResetPWConfirm, requestType: RequestType.post,  endPoint: baseURL + "auth/password/reset/confirm/")
let resendeMailVerification     = RehiveCall(callType: CallType.ResendeMailVerification,   requestType: RequestType.post,  endPoint: baseURL + "auth/email/verify/resend/")
let resendeMobileVerification   = RehiveCall(callType: CallType.ResendeMobileVerification,   requestType: RequestType.post,  endPoint: baseURL + "auth/mobile/verify/resend/")
let emailVerify     = RehiveCall(callType: CallType.ResetPW,     requestType: RequestType.post,  endPoint: baseURL + "auth/auth/email/verify/")
let mobileVerify    = RehiveCall(callType: CallType.ResetPW,     requestType: RequestType.post,  endPoint: baseURL + "auth/auth/email/verify/")

// Transactions
let txnTotal        = RehiveCall(callType: CallType.TxnTotal,       requestType: RequestType.get,   endPoint: baseURL + "transactions/totals/")
let txnList         = RehiveCall(callType: CallType.TxnList,        requestType: RequestType.get,   endPoint: baseURL + "transactions/")
let txnDebit        = RehiveCall(callType: CallType.TxnDebit,       requestType: RequestType.get,   endPoint: baseURL + "transactions/debit/")
let txnCredit       = RehiveCall(callType: CallType.TxnCredit,      requestType: RequestType.post,  endPoint: baseURL + "transactions/credit/")
let txnTransfer     = RehiveCall(callType: CallType.TxnCredit,      requestType: RequestType.post,  endPoint: baseURL + "transactions/transfer/")
let txnRetrieve     = RehiveCall(callType: CallType.TxnRetrieve,    requestType: RequestType.get,   endPoint: baseURL + "transactions/{id}")

// User
let getUsrProfile   = RehiveCall(callType: CallType.GetUsrProfile,  requestType: RequestType.get,   endPoint: baseURL + "user/")
let setUsrProfile   = RehiveCall(callType: CallType.SetUsrProfile,  requestType: RequestType.patch, endPoint: baseURL + "user/")
let getUsrAddress   = RehiveCall(callType: CallType.GetUsrAddress,  requestType: RequestType.get,   endPoint: baseURL + "user/address/")
let setUsrAddress   = RehiveCall(callType: CallType.SetUsrAddress,  requestType: RequestType.patch, endPoint: baseURL + "user/address/")
public let listUsrBankAcc  = RehiveCall(callType: CallType.ListUsrBankAcc, requestType: RequestType.get,   endPoint: baseURL + "user/bank-accounts/")
public let newUsrBankAcc   = RehiveCall(callType: CallType.NewUsrBankAcc,  requestType: RequestType.post,  endPoint: baseURL + "user/bank-accounts/")
public let getUsrBankAcc   = RehiveCall(callType: CallType.GetUsrBankAcc,  requestType: RequestType.get,   endPoint: baseURL + "user/bank-accounts/{account_id}/")
public let setUsrBankAcc   = RehiveCall(callType: CallType.SetUsrBankAcc,  requestType: RequestType.patch, endPoint: baseURL + "user/bank-accounts/{account_id}/")
public let delUsrBankAcc   = RehiveCall(callType: CallType.DelUsrBankAcc,  requestType: RequestType.delete,endPoint: baseURL + "user/bank-accounts/{account_id}/")

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
    if call.callType != CallType.Login {
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

