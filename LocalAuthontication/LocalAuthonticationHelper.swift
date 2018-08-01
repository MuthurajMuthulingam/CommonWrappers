//
//  LocalAuthonticationHelper.swift
//  Entrada
//
//  Created by Muthuraj Muthulingam on 23/07/18.
//  Copyright © 2018 Entrada, Inc. All rights reserved.
//

import UIKit
import LocalAuthentication

enum BiomatricType: String {
    case touchID = "Touch ID"
    case faceID = "Face ID"
    case none = "None"
    
    var image: UIImage? {
        var biomatricImage: UIImage?
        switch self {
        case .touchID:
            biomatricImage = #imageLiteral(resourceName: "touchID")
        case .faceID:
            biomatricImage = #imageLiteral(resourceName: "faceID")
        case .none:
            break
        }
        return biomatricImage
    }
}

typealias AuthonticationCompleteion = ((_ status: Bool, _ errorMessage: String?, _ error: Error?) -> Void)

class LocalAuthonticationHelper {
    
    static let shared: LocalAuthonticationHelper = LocalAuthonticationHelper()
    
    private lazy var laContext: LAContext = LAContext()
    
    // MARK: - Public Helpers
    func supportedBiomatric() -> (type: BiomatricType, error: LAError.Code?) {
        var biomatricType: BiomatricType = .none
        var error: NSError?
        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11, *) {
                biomatricType = (laContext.biometryType == .faceID) ? .faceID : .touchID
            } else {
                biomatricType = .touchID
            }
        }
        return (biomatricType, errorOnBiomatricEvaluation(from: error))
    }
    
    private func errorOnBiomatricEvaluation(from error: NSError?) -> LAError.Code? {
        guard let code = error?._code,
            let laErrorCode = LAError.Code(rawValue: code) else {
            return nil
        }
        return laErrorCode
    }
    
    private func evaluateBiomatric(reason: String, fallBackTitle: String, completion: AuthonticationCompleteion?) {
        func callCompletionOnMainThread(status: Bool, errorMessage: String?, error: Error?) {
            DispatchQueue.main.async {
                completion?(status, errorMessage, error)
            }
        }
        laContext.localizedFallbackTitle = fallBackTitle
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { status, error in
            // handle error here
            if status {
                // invalidate current context
                self.laContext = LAContext() // iOS 8.0
               callCompletionOnMainThread(status: true, errorMessage: nil, error: nil)
            } else {
                if  let code = error?._code,
                    let laErrorCode = LAError.Code(rawValue: code) {
                    callCompletionOnMainThread(status: false, errorMessage: laErrorCode.message, error: error)
                }
            }
        }
    }
}

extension LAError.Code {
    var message: String {
        var errorMessage = "Unknown Message"
        switch self {
        case .appCancel:
            errorMessage = "Authontication cancelled by system"
        case .authenticationFailed:
            errorMessage = "The user failed to provide valid credentials"
        case .invalidContext:
            errorMessage = "The context is invalid"
        case .passcodeNotSet:
            errorMessage = "Passcode is not set on the device"
        case .systemCancel:
            errorMessage = "Authentication was cancelled by the system"
        case .touchIDLockout:
            errorMessage = "Too many failed attempts."
        case .touchIDNotAvailable:
            errorMessage = "Biomatric not available on the device"
        case .touchIDNotEnrolled:
            errorMessage = "Biomatric not enrolled on this device"
        case .userCancel:
            errorMessage = "The user did cancelled the authontication"
        case .userFallback:
            errorMessage = "User chose to fall back"
        default:
            errorMessage = "Unknown error occured while bio matric authontication"
        }
        return errorMessage
    }
    
    var isBiomatricEnabledOnDevice: Bool {
        switch self {
        case .passcodeNotSet, .touchIDNotEnrolled:
            return false
        default:
            return true
        }
    }
    
    var isBiomatricAvailableOnDevice: Bool {
        switch self {
        case .touchIDNotAvailable:
            return false
        default:
            return true
        }
    }
}

// MARK: - biomatric Autontication helpers
extension LocalAuthonticationHelper {
    static func evaluateBiomatricPolicy(of supportedBiomatric: BiomatricType, completion: AuthonticationCompleteion? ) {
        let reasonString = NSLocalizedString("Use \(supportedBiomatric.rawValue) to login", comment: "Use \(supportedBiomatric.rawValue) to login Title")
        let fallBackTitle = NSLocalizedString("Enter PIN", comment: "Enter PIN Title")
        LocalAuthonticationHelper.shared.evaluateBiomatric(reason: reasonString, fallBackTitle: fallBackTitle, completion: completion)
    }
    
    static func isBiomatricEnabledOnApp() -> Bool {
        guard let biomatricEnabled = retriveValueFromUserdefaults(for: String.Constants.UserDefault.enableBiomatricAuthontication) as? Bool else {
            storeValueToUserDefaults(true, for: String.Constants.UserDefault.enableBiomatricAuthontication)
            return true
        }
        return biomatricEnabled
    }
    
    static func enableBiomatricmatricOnApp(shouldEnable: Bool) {
        storeValueToUserDefaults(shouldEnable, for: String.Constants.UserDefault.enableBiomatricAuthontication)
    }
}

