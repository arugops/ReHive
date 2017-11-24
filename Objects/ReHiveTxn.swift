//
//  ReHiveTxn.swift
//  reHiveKit
//
//  Created by Sean on 2017/11/16.
//  Copyright © 2017 Sean. All rights reserved.
//

import Foundation


public struct Transfer    : Codable {
    let amount        : Int
    let recipient     : String

    public static func makeTransfer(_ amt: Int, recipient: String, completionHandler: @escaping (TransferResponse?, Error?) -> Void) {
        var transferJSON:Data?
        let encoder = JSONEncoder()
        do {
//            encoder.outputFormatting = .prettyPrinted
            transferJSON = try encoder.encode(Transfer(amount: amt, recipient: recipient))
//            print(String(data: transferJSON!, encoding: .utf8)!)
        } catch {
            CommonCode.showAlert(title: error.localizedDescription, message: "")
            completionHandler(nil, error)
            return
        }

        if let urlRequest = getURL(call: txnTransfer, httpBody: transferJSON) {
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
                    let reply = try decoder.decode(TransferResponse.self, from: responseData)
                    //                    print("reply: \(reply)")
                    if reply.status == "error" {
                        let detailedError = try decoder.decode(JSONError.self, from: responseData)
 //                       print("detail: \(detailedError)")
                    } else {
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

fileprivate struct RawTransferResponse : Codable {
    let status      : String  // success
    let data        : TransferData?
    
    struct TransferData  : Codable {
        let id           : String?
    }
}

public struct TransferResponse : Codable {
    public var status          : String
    public var txnData         : String
    
    public init(from decoder: Decoder) throws {
        let rawTransferResponse = try RawTransferResponse(from: decoder)
        status      = rawTransferResponse.status
        txnData     = rawTransferResponse.data?.id ?? ""
    }
}

struct RawTransactionList : Codable {
    let status  : String    //"success",
    let data    : Data
    
    struct Data : Codable {
        let count       : Int
        let next        : String?
        let previous    : String?
        let results     : [Results]
    }
    
    struct Results : Codable {
        let id          : String        // "000000000000000000000",
        let tx_type     : String        // "credit",
        let subtype     : String?       // null,
        let note        : String        // "",
//        let metadata    : Metadata      // {},
        let status      : String        // "Complete",
        let reference   : String?        //null,
        let amount      : Int           // 500,
        let fee         : Int           // 0,
        let total_amount: Int           // 500,
        let balance     : Int           // 500,
        let account     : String        //"0000000000",
        let label       : String        //"Credit",
        let company     : String        //"rehive",
        let currency    : Currency
        let user        : RawPartUser
        let source_transaction      : Source_transaction?  //null,
        let destination_transaction : Dest_transaction? //null,
//        let messages    : Messages?
        let created     : Double          // 1476691969394,
        let updated     : Double          // 1496135465287
    }

    struct Metadata: Codable {
        let metadata    : String?
    }

    struct Source_transaction: Codable {
        let metadata    : Bool?
    }

    struct Dest_transaction: Codable {
        let metadata    : Bool?
    }

//    struct Messages :Codable {
//        let level   : String    //"info",
//        let message : String    //"Example Message.",
//        let created : String    //1496144568989
//    }
}

public struct TransactionList : Codable {
    public var status       : String
    public var transactions : [Transaction]

    public struct Transaction : Codable {
        public var label       : String? // Credit
        public var subType     : String?
        public var amount      : Int?
        public var fee         : Int?
        public var company     : String?
        public var currencyCode : String?
        public var userName    : String?
        public var createdDate : Double?
        public var txnStatus   : String?
    }

    public init(from decoder: Decoder) throws {
        //        encoder.dateEncodingStrategy = .iso8601
        let rawTransactionList = try RawTransactionList(from: decoder)
        status       = rawTransactionList.status
        transactions = []
        for result in rawTransactionList.data.results {
//             print("result : \(result)")
            let txn = Transaction.init(label:       result.label ,
                                       subType:     result.subtype ?? "",
                                       amount:      result.amount ,
                                       fee:         result.fee,
                                       company:     result.company,
                                       currencyCode: result.currency.code,
                                       userName:    result.user.username,
                                       createdDate: result.created,
                                       txnStatus :  result.status)
            transactions.append(txn)
        }
    }
}

extension TransactionList {
    public static func getTransactionList( completionHandler: @escaping (TransactionList?, Error?) -> Void) {
        if let urlRequest = getURL(call: txnList, httpBody: nil) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
//                print("response \(response)")
//                print("data \(data)")
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(TransactionList.self, from: data!)
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

public struct TransactionTotals : Codable {
    public let status  : String    //"success",
    public let data    : TransactionSummary
    
    public struct TransactionSummary : Codable {
        public let amount      : Int           // 500,
        public let fees        : Int           // 0,
        public let count       : Int           // 500,
        public let currency    : String
    }
}

extension TransactionTotals {
    public static func getTotal( completionHandler: @escaping (TransactionTotals?, Error?) -> Void) {
        if let urlRequest = getURL(call: txnTotal, httpBody: nil) {
            let task = hiveSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                guard error == nil else {
                    completionHandler(nil, error!)
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let reply = try decoder.decode(TransactionTotals.self, from: data!)
                    //                print("reply: \(reply)")
                    if reply.status == "error" {
                        completionHandler(nil, error!)
                        //                        let detailedError = try decoder.decode(JSONError.self, from: data!)
                        //                        print("detail: \(detailedError)")
                    } else {
                        completionHandler(reply, nil)
                    }
                } catch {
                    //                    print(ErrorAction.ErrorActionJSON3)
                    //                    print(error)
                    completionHandler(nil, error)
                }
            })
            task.resume()
        }
    }
    
}
