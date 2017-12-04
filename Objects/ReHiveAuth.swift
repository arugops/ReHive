//
//  hives.swift
//  sendTest
//
//  Created by Remittance Dev Mac on 2017/11/08.
//  Copyright © 2017 Remittance Dev Mac. All rights reserved.
//

import Foundation

/*
 Login.userLogin
 Logout.userLogout       - for single toke or all tokens
 Register.registerAll    - for both user & company
 ChangePassWord.changePassword
 ResetPassWord.resetPassWord
 ResetPassWordConfirm.resetPassWordConfirm
 ResendeMailVerification.resendeMail
 ResendeMobileVerification.resendeMobile
 VerifyeMail.verifyeMail
 VerifyeMobile.verifyMobile
*/

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
            completionHandler(nil, error)
            return
        }
        
        if let urlRequest = getURL(call: login, httpBody: loginJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
                guard let responseData = data else {
                    let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON2)
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
                    if reply.status == "success" {
                        currentToken = reply.token
                    }
                    completionHandler(reply, nil)
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

public struct Logout    : Codable {

    public static func userLogout(_ rehiveCall : RehiveCall , completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let logoutJSON = try encoder.encode(Logout())
            if let urlRequest = getURL(call: rehiveCall, httpBody: logoutJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct Register : Codable {
    let first_name           : String
    let last_name            : String
    let email                : String
    let company              : String
    let password1            : String
    let password2            : String
    let terms_and_conditions : Bool?
    
    public static func registerAll (_ isUser    : Bool,     // Can register user or Company
                                   firstName    : String,
                                   lastName     : String,
                                   email        : String,
                                   company      : String,
                                   pw1          : String,
                                   pw2          : String,
                                   termsAgreed  : Bool,
                                   completionHandler: @escaping (LoginResponse?, Error?) -> Void) {
        var registerJSON:Data?
        let encoder = JSONEncoder()
        do {
            registerJSON = try encoder.encode(Register(first_name: firstName,
                                                       last_name: lastName,
                                                       email: email,
                                                       company: company,
                                                       password1: pw1,
                                                       password2: pw2,
                                                       terms_and_conditions: termsAgreed))
        } catch {
            completionHandler(nil, error)
            return
        }
        
        var rehiveCallType : RehiveCall
        if isUser {
            rehiveCallType = register
        } else {
            rehiveCallType = registerCompany
        }
        
        if let urlRequest = getURL(call: rehiveCallType, httpBody: registerJSON) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
                guard let responseData = data else {
                    let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON2)
                    completionHandler(nil, error)
                    return
                }
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(LoginResponse.self, from: responseData)
                    if reply.status == "success" {
                        currentToken = reply.token
                    }
                    completionHandler(reply, nil)
                } catch {
                    completionHandler(nil, error)
                }
            })
            task.resume()
        }
    }
}

public struct ChangePassWord : Codable {
    let old_password             : String
    let new_password1            : String
    let new_password2            : String
    
    public static func changePassWord (_ oldPassword      : String,
                                        pw1          : String,
                                        pw2          : String,
                                        completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(ChangePassWord(old_password: oldPassword, new_password1: pw1, new_password2: pw2))
            if let urlRequest = getURL(call: changePassword, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct ResetPassWord : Codable {
    let user             : String
    let company          : String
    
    public static func resetPassWord (_ user      : String,
                                       company     : String,
                                       completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(ResetPassWord(user: user, company: company))
            if let urlRequest = getURL(call: changePassword, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct ResetPassWordConfirm : Codable {
    let new_password1       : String
    let new_password2       : String
    let uid                 : String
    let token               : String
    
    public static func resetPassWordConfirm (_ pw1    : String,
                                             pw2      : String,
                                             uid      : String,
                                             token    : String,
                                             completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(ResetPassWordConfirm(new_password1: pw1, new_password2: pw2, uid: uid, token: token))
            if let urlRequest = getURL(call: resetPWConfirm, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
            return
        }
    }
}

public struct ResendeMailVerification : Codable {
    let email                 : String
    let company               : String
    
    public static func resendEmail (_ email    : String, company    : String,
                                       completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(ResendeMailVerification(email: email, company: company))
            if let urlRequest = getURL(call: resendeMailVerification, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct ResendeMobileVerification : Codable {
    let mobile                 : String
    let company                : String
    
    public static func resendMobile (_ mobile    : String, company    : String,
                                    completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(ResendeMobileVerification(mobile: mobile, company: company))
            if let urlRequest = getURL(call: resendeMobileVerification, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct VerifyMobile : Codable {
    let otp                 : String
    
    public static func verifyMobile (_ otp : String, completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(VerifyMobile(otp: otp))
            if let urlRequest = getURL(call: mobileVerify, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

public struct VerifyeMail : Codable {
    let key                 : String
    
    public static func verifyeMail (_ key : String, completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let passwordJSON = try encoder.encode(VerifyeMail(key: key))
            if let urlRequest = getURL(call: emailVerify, httpBody: passwordJSON) {
                getResponse(from: urlRequest, completionHandler: { (response, err) in
                    completionHandler(response, err)
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}

fileprivate struct RawPasswordResponse : Codable {
    let status          : String  // success
}

public struct PasswordResponse : Codable {
    public var status      : String
    
    public init(from decoder: Decoder) throws {
        let rawPasswordResponse = try RawPasswordResponse(from: decoder)
        status          = rawPasswordResponse.status
    }
}

func getResponse(from currentRequest : URLRequest,completionHandler: @escaping (PasswordResponse?, Error?) -> Void) {
    let task = hiveSession.dataTask(with: currentRequest, completionHandler: {(data, response, error) in
        guard let responseData = data else {
            let error = BackendError.urlError(reason: ErrorAction.ErrorActionJSON2)
            completionHandler(nil, error)
            return
        }
        guard error == nil else {
            completionHandler(nil, error!)
            return
        }
        let decoder = JSONDecoder()
        do {
            let reply = try decoder.decode(PasswordResponse.self, from: responseData)
            completionHandler(reply, nil)
        } catch {
            completionHandler(nil, error)
        }
    })
    task.resume()
}
