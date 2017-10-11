//
//  TouchIdAuthentication.swift
//  TipStr
//
//  Created by Sanjib Chakraborty on 12/30/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit
import LocalAuthentication

typealias TouchIdValidationCallBack = (_ isValid: Bool, _ errorString: String?) -> ()

class TouchIdAuthentication {
    
    func isTouchIdAvailable() -> Bool {
        var error: NSError?
        var isTouchIDAvailable = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let errorCode = error?.code {
            switch  errorCode {
            case LAError.touchIDNotEnrolled.rawValue:
                isTouchIDAvailable = true
            case LAError.touchIDNotAvailable.rawValue:
                isTouchIDAvailable = false
            default :
                isTouchIDAvailable = false
            }
        }
        return isTouchIDAvailable
    }
    
    func validateTouchId(callBack: @escaping TouchIdValidationCallBack) {
        
        let reasonString = "Use Touch ID for authentication."
        
        let context = LAContext()
        
        //To remove 'enter password' button
        context.localizedFallbackTitle = ""
        
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) == true {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reasonString,
                reply: { (isSuccess, error) in
                    
                    if isSuccess == true {
                        DispatchQueue.main.async {
                            callBack(true, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            callBack(false, self.getErrorString(errorCode: (error as! NSError).code))
                        }
                    }
            })
        } else {
            DispatchQueue.main.async {
                callBack(false, self.getErrorString(errorCode: (error?.code)!))
            }
        }
    }
    
    func getErrorString(errorCode: Int) -> String {
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "Invalid credentials"
            
        case LAError.userCancel.rawValue:
            message = "Authentication cancelled by user"
            
        case LAError.userFallback.rawValue:
            message = "User opt for Passcode"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by system"
            
        case LAError.passcodeNotSet.rawValue:
            message = "No passcode setup on device"
            
        case LAError.touchIDNotAvailable.rawValue:
            message = "Touch ID not available on the device"
            
        case LAError.touchIDNotEnrolled.rawValue:
            message = "No enrolled fingers"
            
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts. Enter passcode"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "This call has been previously invalidated"
            
        default :
            message = "Error"
        }
        
        return message
    }
}
