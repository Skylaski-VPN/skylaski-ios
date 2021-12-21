//
//  StoreHandler.swift
//  skylaski
//
//  Created by Anilkumar on 18/05/21.
//

import UIKit
import StoreKit

protocol PaymentControlDelegate: AnyObject {
    func purchaseFailed(with error: String)
    func purchaseSuccess()
    func purchaseRestored()
}

class SkyAppStoreHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    private let kInAppPurchasingErrorNotification           =   "InAppPurchasingErrorNotification"

    private let autorenewableIndividualProductId =   "Sky_PRO1"
    private let autorenewableMultipleProductId   =   "Sky_PRO3"
    private let autorenewableLotsOffProductId    =   "Sky_PRO4"
    
    private let onetimeFreeTrialProductId        =   "Sky_PRO7"

    static let sharedInstance                               =   SkyAppStoreHelper()

    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    var products = [SKProduct]()
    private var purchasing = false

    //******** for testing purpose only ********************//
//    #if DEBUG
//        let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
//    #else
//        let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
//    #endif

    override init() {
        super.init()

        SKPaymentQueue.default().add(self)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error %@ \(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppPurchasingErrorNotification), object: error.localizedDescription)
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("Transactions Removed : \(transactions[0].payment.productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transactions[0])
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Restoring Completed Transactions")
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response)
        print("productsRequest: Got the request from Apple")

        let productsInfo = response.products

        if productsInfo.count == 1 && purchasing == false {
            self.products = productsInfo

            for item : SKProduct in productsInfo {
                print(item.localizedTitle)
                print(item.price)
                print(item.priceLocale.currencySymbol as Any)
                print(item.productIdentifier)
            }

        }
        else if productsInfo.count == 1 && purchasing == true{
            let validProduct: SKProduct = productsInfo[0]
            print(validProduct.localizedTitle)
            print(validProduct.localizedDescription)
            print(validProduct.price)
            buyProduct(validProduct);
        }
        else {
            print("No products")
        }
    }
    
    // Buy Product Request
    /*func buyRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response)
        print("buyRequest: Got the request from Apple")

        let productsInfo = response.products

        if productsInfo.count == 1 {
            let validProduct: SKProduct = productsInfo[0]
            print(validProduct.localizedTitle)
            print(validProduct.localizedDescription)
            print(validProduct.price)
            print("Buying Product")
            buyProduct(validProduct);
        }
        else {
            print("No products")
        }
    }*/

    func buyProduct(_ product: SKProduct) {
        print("Sending the Payment Request to Apple")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");

        for transaction: AnyObject in transactions {
            if let trans: SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased, .restored:
                    print("Product Purchased",trans.payment.productIdentifier, trans.transactionIdentifier as Any)
                    savePurchasedProductIdentifier(trans.payment.productIdentifier)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)


                    let receiptFileURL = Bundle.main.appStoreReceiptURL
                    let receiptData = try? Data(contentsOf: receiptFileURL!)
                    let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                    let jsonDict = ["receipt" : recieptString! ,"testing": false, "transaction_id" : trans.transactionIdentifier as Any ] as [String : Any]

                    ApiCallController().updatePayment(params: jsonDict)

                    break

                case .failed:
                    print("Purchased Failed : \(String(describing: trans.error?.localizedDescription))")

                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    NotificationCenter.default.post(name: .failed, object: nil)
                    if let currentVC = UIApplication.topViewController() as? PricingViewController {
                        currentVC.showAlert( message: trans.error?.localizedDescription ?? "Payment failed!!")
                    }
                    break
                case .purchasing:
                    print("Product Purchasing")
                default:
                    break
                }
            }

        }
    }

    func savePurchasedProductIdentifier(_ productIdentifier: String!) {
        UserDefaults.standard.set(productIdentifier, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
    }

    //******** for testing purpose only ********************//
    
//    func receiptValidation() {
//        let receiptFileURL = Bundle.main.appStoreReceiptURL
//        let receiptData = try? Data(contentsOf: receiptFileURL!)
//        let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "c918749d226a4d26b8643c5b7345b49c" as AnyObject]
//
//        do {
//            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
//            let storeURL = URL(string: verifyReceiptURL)!
//            var storeRequest = URLRequest(url: storeURL)
//            storeRequest.httpMethod = "POST"
//            storeRequest.httpBody = requestData
//
//            let session = URLSession(configuration: URLSessionConfiguration.default)
//            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
//
//                do {
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
//                    print("jsonResponse",jsonResponse)
//                    if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
//                        print("date",date)
//                    }
//                } catch let parseError {
//                    print("errrrrrr",parseError)
//                }
//            })
//            task.resume()
//        } catch let parseError {
//            print("erorrrrrr",parseError)
//        }
//    }

    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {

        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {

            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"

            if let expiresDate = lastReceipt["expires_date"] as? String {
                return formatter.date(from: expiresDate)
            }

            return nil
        }
        else {
            return nil
        }
    }

    func unlockPackage(_ productIdentifier: String!) {
        if isAuthorizedForPayments , let id = productIdentifier{
            let productID: NSSet                    =   NSSet(object: id)
            let buyRequest: SKProductsRequest  =   SKProductsRequest(productIdentifiers: productID as! Set<String>)
            buyRequest.delegate = self

            purchasing = true
            buyRequest.start()

            print("unlockPackage: Fetching Products")
        }else {
            print("Can't make purchases")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kInAppPurchasingErrorNotification), object: NSLocalizedString("CANT_MAKE_PURCHASES", comment: "Can't make purchases"))
        }
    }

    func getPriceOfProduct
    () {
        //******************************* for all products
//        let productIds: NSSet                   =   NSSet(array: [ onetimeFreeTrialProductId,autorenewableIndividualProductId,autorenewableMultipleProductId, autorenewableLotsOffProductId])
        //****************************** for trial products
        
        let productIds: NSSet                   =   NSSet(array: [ onetimeFreeTrialProductId])
        
        let productsRequest: SKProductsRequest  =   SKProductsRequest(productIdentifiers: productIds as! Set<String>)
        productsRequest.delegate                =   self

        productsRequest.start()
    }

    func priceOf(product: SKProduct) -> String {
        let numberFormatter                 =   NumberFormatter()
        numberFormatter.formatterBehavior   =   .behavior10_4
        numberFormatter.numberStyle         =   .currency
        numberFormatter.locale              =   product.priceLocale

        return numberFormatter.string(from: product.price)!
    }
}
