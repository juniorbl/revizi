//
//  StoreHelper.swift
//  Revizi
//
//  Created by Carlos on 2019-01-28.
//  Copyright © 2019 Carlos Luz. All rights reserved.
//

import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ availableProducts: [SKProduct]?) -> Void

class StoreHelper: NSObject {
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productIDs: Set<String>?
    private var purchasedProductIDs: Set<String> = []
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    init(productIds: Set<String>) {
        self.productIDs = productIds
        // TODO implement in-app receipt validation in a later version
        for productId in productIds {
            // for now before the implementation of receipt validation, just for another layer of protections since the user properties can be modified,
            // get the hash value of the value saved and compare with the hash value of the unlimited subjects key name
            let purchased = UserDefaults.standard.string(forKey: sha256(value: productId)) == sha256(value: UnlimitedSubjects.purchasedProductKeyname)
            if purchased {
                purchasedProductIDs.insert(productId)
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchAvailableProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        if productIDs?.isEmpty ?? true {
            NSLog("List of product ids is empty")
            return
        }
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIDs!)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    func isProductPurchased(_ productId: String) -> Bool {
        return purchasedProductIDs.contains(productId)
    }
    
    public func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension StoreHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            let availableProducts = response.products
            productsRequestCompletionHandler?(true, availableProducts)
            clearRequestAndHandler()
        } else {
            productsRequestCompletionHandler?(false, nil)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        NSLog("Error while retriving products: \(error)")
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension StoreHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(productId: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productId = transaction.original?.payment.productIdentifier else { return }
        
        deliverPurchaseNotificationFor(productId: productId)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            NSLog("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(productId: String?) {
        guard let purchasedProductId = productId else { return }
        
        purchasedProductIDs.insert(purchasedProductId)
        // for now, hashing the product id and a value specific to unlimited subjects before saving
        UserDefaults.standard.set(sha256(value: UnlimitedSubjects.purchasedProductKeyname), forKey: sha256(value: purchasedProductId))
        NotificationCenter.default.post(name: .StoreHelperPurchaseNotification, object: purchasedProductId)
    }
}

extension Notification.Name {
    static let StoreHelperPurchaseNotification = Notification.Name("StoreHelperPurchaseNotification")
}

// the functions below is to get a sha hash value for a given string
func sha256(value: String) -> String{
    if let stringData = value.data(using: String.Encoding.utf8) {
        return hexStringFromData(input: digest(input: stringData as NSData))
    }
    return ""
}

private func digest(input : NSData) -> NSData {
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](repeating: 0, count: digestLength)
    CC_SHA256(input.bytes, UInt32(input.length), &hash)
    return NSData(bytes: hash, length: digestLength)
}

private  func hexStringFromData(input: NSData) -> String {
    var bytes = [UInt8](repeating: 0, count: input.length)
    input.getBytes(&bytes, length: input.length)
    
    var hexString = ""
    for byte in bytes {
        hexString += String(format:"%02x", UInt8(byte))
    }
    
    return hexString
}
