//
//  hives.swift
//  sendTest
//
//  Created by Remittance Dev Mac on 2017/11/08.
//  Copyright © 2017 Remittance Dev Mac. All rights reserved.
//

import Foundation

public struct Login    : Codable {
    let user        : String        // email, mobile number, or unique identifier
    let company     : String
    let password    : String
//    let session_duration : Int
    
    public static func userLogin(_ userName: String, company: String, pw: String, completionHandler: @escaping (LoginResponse?, Error?) -> Void) {
        var loginJSON:Data?
        let encoder = JSONEncoder()
        do {
//            encoder.outputFormatting = .prettyPrinted
            loginJSON = try encoder.encode(Login(user: userName, company: company, password: pw))
            //            print(String(data: loginJSON, encoding: .utf8)!)
        } catch {
            CommonCode.showAlert(title: error.localizedDescription, message: "")
            completionHandler(nil, error)
            return
        }
        
        if let urlRequest = getURL(call: login, httpBody: loginJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
                guard let responseData = data else {
                    let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON2)
                    CommonCode.showAlert(title: error.localizedDescription, message: "")
                    completionHandler(nil, error)
                    return
                }
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                //            print("response \(response)")
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(LoginResponse.self, from: responseData)
//                    print("reply: \(reply)")
                    if reply.status == "error" {
                        let detailedError = try decoder.decode(JSONError.self, from: responseData)
                        print("detail: \(detailedError)")
                    } else {
                        currentToken = reply.token
                        //                            print("Got token \(currentToken) ")
                        completionHandler(reply, nil)
                    }
                } catch {
                    completionHandler(nil, error)
                }
            })
            task.resume()
        } else {
            // Unable to get a login URL
        }
    }
}

// Login Response
fileprivate struct RawLoginResponse : Codable {
    let status      : String  // success
    let data        : ResponseData

    struct ResponseData     : Codable {
        let token           : String?
        let user            : RawUser
        let kyc             : KYC?
        let status          : String?     //pending,
        let permissions_groups : Permission_groups?
        let permissions     : String?
        let date_joined     : Date?
        let switches        : String?
    }

    struct Permission_groups: Codable {
        let name        : [String?]    //admin
    }
    
}

struct KYC  : Codable {
    let documents    : Documents
    let updated      : Date
    let status       : String     //pending,
    let bank_accounts : Bank_accounts
    let addresses    : Addresses
}

struct Documents: Codable {
    let updated : String
    let status  : String
}

struct Bank_accounts: Codable {
    let updated : String
    let status  : String
}

struct Addresses: Codable {
    let updated : String
    let status  : String
}

struct Metadata: Codable {
    let metadata    : String?
}

public struct LoginResponse : Codable {
    public var status      : String
    public var userName    : String
    public var token       : String
    public var user        = User()

    public init(from decoder: Decoder) throws {
        let rawLoginResponse = try RawLoginResponse(from: decoder)
        status          = rawLoginResponse.status
        userName        = rawLoginResponse.data.user.first_name ?? "EMPTY"
        token           = rawLoginResponse.data.token ?? "NIL"
        
        user.identifier     = rawLoginResponse.data.user.identifier!
        user.firstName      = rawLoginResponse.data.user.first_name     ?? ""
        user.lastName       = rawLoginResponse.data.user.last_name      ?? ""
        user.email          = rawLoginResponse.data.user.email          ?? ""
        user.idNumber       = rawLoginResponse.data.user.id_number      ?? ""
        user.birthDate      = rawLoginResponse.data.user.birth_date
        user.profile        = rawLoginResponse.data.user.profile        ?? ""
        user.currency       = rawLoginResponse.data.user.currency?.currency ?? ""
        user.company        = rawLoginResponse.data.user.company        ?? ""
        user.language       = rawLoginResponse.data.user.language       ?? ""
        user.nationality    = rawLoginResponse.data.user.nationality    ?? ""
        user.mobileNumber   = rawLoginResponse.data.user.mobile_number  ?? ""
        user.timezone       = rawLoginResponse.data.user.timezone       ?? ""
        user.verified       = rawLoginResponse.data.user.verified       ?? false
    }
}

/*extension TransactionTotals {
    static func getTotal( completionHandler: @escaping (TransactionTotals?, Error?) -> Void) {
        if let urlRequest = getURL(call: txnTotal, httpBody: nil) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard let responseData = data else {
                    //print(ErrorAction.ErrorActionJSON2)
                    completionHandler(nil, error)
                    return
                }
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                // print("response \(response)")
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(TransactionTotals.self, from: responseData)
                    //                print("reply: \(reply)")
                    if reply.status == "error" {
                        let detailedError = try decoder.decode(JSONError.self, from: responseData)
                        print("detail: \(detailedError)")
                    } else {
                        completionHandler(reply, nil)
                    }
                } catch {
                    print(ErrorAction.ErrorActionJSON3)
                    print(error)
                    completionHandler(nil, error)
                }
            })
            task.resume()
        }
    }
    
}
*/
/*
 guard let url = URL(string: TransactionTotals.endPoint) else {
 print(ErrorAction.ErrorActionJSON1)
 let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON1)
 completionHandler(nil, error)
 return
 }
 var urlRequest = URLRequest(url: url)
 urlRequest.httpMethod = "GET"
 let authorizationKey = "Token "+currentToken
 var headers = urlRequest.allHTTPHeaderFields ?? [:]
 headers["Content-Type"] = "application/json"
 urlRequest.allHTTPHeaderFields = headers
 urlRequest.addValue(authorizationKey, forHTTPHeaderField: "Authorization")
 
 print("Headers \(urlRequest.allHTTPHeaderFields)")
 //        let session = URLSession.shared

 */
//"user": {
//    "identifier": "00000000-0000-0000-0000-000000000000",
//    "first_name": "Joe",
//    "last_name": "Soap",
//    "email": "joe@rehive.com",
//    "username": "",
//    "mobile_number": "+27840000000",
//    "profile": null
//},

/*
 {
 //        let endpoint = Login.endpointForLogin()
 //        guard let url = URL(string: endpoint) else {
 //            print(ErrorAction.ErrorActionJSON1)
 //            let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON1)
 //            completionHandler(nil, error)
 //            return
 //        }
 //        var urlRequest = URLRequest(url: url)
 ////        urlRequest.httpMethod = "POST, OPTIONS"
 //        urlRequest.httpMethod = "POST"
 //
 //        var headers = urlRequest.allHTTPHeaderFields ?? [:]
 //        headers["Content-Type"] = "application/json"
 //        urlRequest.allHTTPHeaderFields = headers
 //
 //        let login = Login(user: "sean.evans@flash.co.za", company: "flashtest", password: "Summer17")
 //
 var loginJSON:Data?
 let encoder = JSONEncoder()
 do {
 encoder.outputFormatting = .prettyPrinted
 loginJSON = try encoder.encode(Login(user: userName, company: company, password: pw))
 //            print(String(data: loginJSON, encoding: .utf8)!)
 //            urlRequest.httpBody = loginJSON
 //            print("Request1 \(urlRequest)")
 //            print("Request2 \(urlRequest.debugDescription)")
 //            if let bodyData = urlRequest.httpBody {
 //                print(String(data: bodyData, encoding: .utf8) ?? "no body data")
 //            }
 } catch {
 print(error)
 completionHandler(nil, error)
 }
 if loginJSON != nil {
 if let urlRequest = getURL(call: login, httpBody: loginJSON) {
 
 //        let session = URLSession.shared
 let task = hiveSession.dataTask(with: urlRequest, completionHandler: {
 (data, response, error) in
 guard let responseData = data else {
 print(ErrorAction.ErrorActionJSON2)
 completionHandler(nil, error)
 return
 }
 guard error == nil else {
 completionHandler(nil, error!)
 return
 }
 
 //            print("response \(response)")
 
 let decoder = JSONDecoder()
 do {
 let reply = try decoder.decode(LoginResponse.self, from: responseData)
 print("reply: \(reply)")
 if reply.status == "error" {
 let detailedError = try decoder.decode(JSONError.self, from: responseData)
 print("detail: \(detailedError)")
 } else {
 currentToken = reply.token
 //                    currentToken = (reply.data.first?.token)!     // reply.data.token
 print("Got token \(currentToken) ")
 completionHandler(reply, nil)
 }
 } catch {
 //                print(ErrorAction.ErrorActionJSON3)
 //                print(error)
 completionHandler(nil, error)
 }
 })
 task.resume()
 } else {
 // Unable to get a login URL
 }
 }
 }
 */

