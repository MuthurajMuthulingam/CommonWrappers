//
//  UserDefaults + Extensions.swift
//  Entrada
//
//  Created by Muthuraj Muthulingam on 24/07/18.
//  Copyright © 2018 Entrada, Inc. All rights reserved.
//

import Foundation

func storeValueToUserDefaults(_ value: Any, for key: String) {
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func retriveValueFromUserdefaults(for key: String) -> Any? {
    return UserDefaults.standard.value(forKey: key)
}

// MARK: - User Defaults Key Constants
extension String {
    struct Constants {
        enum UserDefault {
            static var bioMatricAlertShown = "BioMatricAlertShown"
            static var enableBiomatricAuthontication = "enableBiomatricAuthontication"
        }
    }
}
