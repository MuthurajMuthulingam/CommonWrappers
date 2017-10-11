//
//  Stripe.swift
//  TipStr
//
//  Created by Muthuraj on 21/02/17.
//  Copyright © 2017 YMedia Labs. All rights reserved.
//

import UIKit
import Stripe
// As Fabric instantiation happens along with stripe, this was included.
import Fabric
import Crashlytics

/// Card details for Stripe Processing
struct StripeCard {
	var cardNumber:String = ""
	var expiryMonth:UInt = 0
	var expiryYear:UInt = 0
	var cvc:String = ""
	var cardHolderName:String = ""
}

class StripeHandler: NSObject {

	/// shared Instance of Stripe Handler
	static let shared = {
		return StripeHandler()
	}
	
	//MARK: - Initializers
	/// @discuission, to avoid called by other classes
	override private init() {
		super.init()
	}
	
	//MARK: - Public methods
	/// this will configuare Stripe Key, to be called in App delegate
	class func configureStripeKey(){
		Stripe.setDefaultPublishableKey(Credential.Stripe.live.rawValue)
	}
	
	/// instantaiate Fabric with crashlatics and Stripe, to be called in App delegate
	class func instantiateFabricsWithStripe(){
		Fabric.with([Crashlytics.self,STPAPIClient.self])
	}
	
	/// create stripe Token from the Card information
	///
	/// - Parameters:
	///   - card: card information
	///   - completion: handler to indicate the token creation process
	class func generateToken(from card:StripeCard,completion:((_ status:Bool, _ token:String?,_ error:Error?) -> (Void))?) {
		let cardParams = STPCardParams()
		cardParams.number = card.cardNumber
		cardParams.expYear = card.expiryYear
		cardParams.expMonth = card.expiryMonth
		cardParams.cvc = card.cvc
		cardParams.name = card.cardHolderName
		// make api call to Stripe to get a token
		STPAPIClient.shared().createToken(withCard: cardParams) {token, error in
			guard let stripeToken = token else {  
				// token creation fails, investigate error
				if let handler = completion {
					handler(false, nil, error)
				}
				return
			}
			if let handler = completion {
				handler(true, "\(stripeToken)", nil)
			}
		}

	}
}
