//
//  Analytics.swift
//  TipStr
//
//  Created by Muthuraj Muthulingam on 25/07/17.
//  Copyright © 2017 YMedia Labs. All rights reserved.
//

import Foundation

enum Analytics:String {
    // Home
    case leaveTip
    case getTip
    // Menu
    case home
    case faq
    case generalSupport
    case logout
    // Profile
    case paymentHistory
    case orgDetails
    case withdraw
    // Bank
    case addBank
    case deleteBank
    // Card
    case addCard
    case deleteCard
    // Settings
    case notification
    case touchID
    case changePasscode
    
    case none
    
    func category() ->String {
        var category = rawValue
        switch self {
        case .leaveTip,.getTip:
            category = "Home"
        case .home,.faq,.generalSupport,.logout:
            category = "Menu"
        case .paymentHistory,.withdraw,.orgDetails:
            category = "Profile"
        case .addBank,.deleteBank:
            category = "Bank"
        case .addCard,.deleteCard:
            category = "Card"
        case .notification,.touchID,.changePasscode:
            category = "Settings"
        default:
            break
        }
        return category
    }
}
