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
    case GET    = "GET"
    case PUT    = "PUT"
    case POST   = "POST"
    case PATCH  = "PATCH"
    case DELETE = "DELETE"
}

public enum CallType : String {
    case Login                  = "Login"
    case Logout                 = "Logout"
    case TxnList                = "List Transactions"
    case TxnTotal               = "Total Transactions"
    case TxnDebit               = "Create Debit"
    case TxnCredit              = "Create Credit"
    case TxnTransfer            = "Create Transfer"
    case TxnRetrieve            = "Retrieve Transactions"
    case GetUsrProfile          = "Retrieve Profile"
    case SetUsrProfile          = "Update Profile"
    case GetUsrAddress          = "Retrieve Address"
    case SetUsrAddress          = "Update Address"
    case ListUsrBankAcc         = "Retrieve Bank account list"
    case NewUsrBankAcc          = "Create Bank account"
    case GetUsrBankAcc          = "Retrieve Bank account"
    case SetUsrBankAcc          = "Update Bank account"
    case DelUsrBankAcc          = "Delete Bank account"
}

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

struct RehiveCall {
    var callType    : CallType
    var requestType : RequestType
    var endPoint    : String
}

let login           = RehiveCall(callType: CallType.Login,       requestType: RequestType.POST,  endPoint: baseURL + "auth/login/")
let logout          = RehiveCall(callType: CallType.Logout,      requestType: RequestType.POST,  endPoint: baseURL + "auth/logout/")
let txnTotal        = RehiveCall(callType: CallType.TxnTotal,    requestType: RequestType.GET,   endPoint: baseURL + "transactions/totals/")
let txnList         = RehiveCall(callType: CallType.TxnList,     requestType: RequestType.GET,   endPoint: baseURL + "transactions/")
let txnDebit        = RehiveCall(callType: CallType.TxnDebit,    requestType: RequestType.GET,   endPoint: baseURL + "transactions/debit/")
let txnCredit       = RehiveCall(callType: CallType.TxnCredit,   requestType: RequestType.POST,  endPoint: baseURL + "transactions/credit/")
let txnTransfer     = RehiveCall(callType: CallType.TxnCredit,   requestType: RequestType.POST,  endPoint: baseURL + "transactions/transfer/")
let txnRetrieve     = RehiveCall(callType: CallType.TxnRetrieve, requestType: RequestType.GET,   endPoint: baseURL + "transactions/{id}")

let getUsrProfile   = RehiveCall(callType: CallType.GetUsrProfile,  requestType: RequestType.GET,   endPoint: baseURL + "user/")
let setUsrProfile   = RehiveCall(callType: CallType.SetUsrProfile,  requestType: RequestType.PATCH, endPoint: baseURL + "user/")
let getUsrAddress   = RehiveCall(callType: CallType.GetUsrAddress,  requestType: RequestType.GET,   endPoint: baseURL + "user/address/")
let setUsrAddress   = RehiveCall(callType: CallType.SetUsrAddress,  requestType: RequestType.PATCH, endPoint: baseURL + "user/address/")
let listUsrBankAcc  = RehiveCall(callType: CallType.ListUsrBankAcc, requestType: RequestType.GET,   endPoint: baseURL + "user/bank-accounts/")
let newUsrBankAcc   = RehiveCall(callType: CallType.NewUsrBankAcc,  requestType: RequestType.POST,  endPoint: baseURL + "user/bank-accounts/")
let getUsrBankAcc   = RehiveCall(callType: CallType.GetUsrBankAcc,  requestType: RequestType.GET,   endPoint: baseURL + "user/bank-accounts/{account_id}/")
let setUsrBankAcc   = RehiveCall(callType: CallType.SetUsrBankAcc,  requestType: RequestType.PATCH, endPoint: baseURL + "user/bank-accounts/{account_id}/")
let delUsrBankAcc   = RehiveCall(callType: CallType.DelUsrBankAcc,  requestType: RequestType.DELETE,endPoint: baseURL + "user/bank-accounts/{account_id}/")

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
        let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON1)
        CommonCode.showAlert(title: error.localizedDescription, message: "")
        return nil
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = call.requestType.rawValue
    if call.requestType == RequestType.POST {
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
//    enum CodingKeys : String, CodingKey {
//        case currencyDesc    = "description"
//        case currencyCode    = "code"
//        case currencySymbol  = "symbol"
//        case currencyUnit    = "unit"
//        case currencyDivisibility = "divisibility"
//    }
}

class CommonCode {
    
    class func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        
        var alertWindow : UIWindow!
        alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController.init()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true)
    }
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

