//
//  Stripe+ApplePay.swift
//  TipStr
//
//  Created by Muthuraj on 21/02/17.
//  Copyright © 2017 YMedia Labs. All rights reserved.
//

import Foundation
import PassKit
import Stripe

extension StripeHandler {
	
	class func canMakePayments() -> Bool {
		if #available(iOS 10.0, *) {
			return PKPaymentAuthorizationController.canMakePayments()
		} else {
			// Fallback on earlier versions
			return PKPaymentAuthorizationViewController.canMakePayments()
		}
	}
    
    class func canMakePaymentsWithCards() -> Bool {
        if #available(iOS 10.0, *) {
            return PKPaymentAuthorizationController.canMakePayments(usingNetworks: [.amex,.discover,.visa,.masterCard])
        } else {
            // Fallback on earlier versions
            return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.amex,.discover,.visa,.masterCard])
        }
    }
	
	class func createPaymentRequest(with desc:String, amount:String) -> PKPaymentRequest{
		// get payment Request object from Stripe with current Merchant ID
		let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: Credential.Stripe.applyPay.rawValue)
		paymentRequest.supportedNetworks = [.amex,.discover,.visa,.masterCard]
		paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: desc, amount: NSDecimalNumber(string: amount))]
		return paymentRequest
	}
	
	class func checkValidityOf(paymentRequest:PKPaymentRequest) -> Bool{
		return Stripe.canSubmitPaymentRequest(paymentRequest)
	}
	
	class func isDeviceSupportApplePay() -> Bool{
		return Stripe.deviceSupportsApplePay()
	}
	
	class func configureStripeApplePay(){
		STPPaymentConfiguration.shared().appleMerchantIdentifier = Credential.Stripe.applyPay.rawValue
	}
}
