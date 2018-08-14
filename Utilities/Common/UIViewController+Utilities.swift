//
//  UIViewController+Utilities.swift
//  Entrada
//
//  Created by Muthuraj Muthulingam on 24/07/18.
//  Copyright © 2018 Entrada, Inc. All rights reserved.
//

import Foundation

typealias AlertActionBlock = ((UIAlertAction) -> Void)

protocol UIAlertRules {
    func showDialogAlert(with title: String,_ message: String,_ okTitle: String,_ cancelTitle: String,_ okAction: AlertActionBlock?,_ cancelAction: AlertActionBlock?)
    func showAlert(with title: String, message: String, okButtonTitle: String, okButtonAction: AlertActionBlock?)
}

extension UIAlertRules where Self: UIViewController {
    func showDialogAlert(with title: String,
                         _ message: String,
                         _ okTitle: String,
                         _ cancelTitle: String,
                         _ okAction: AlertActionBlock? = nil,
                         _ cancelAction: AlertActionBlock? = nil) {
        let uiAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: okAction)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
        uiAlert.addAction(okAction)
        uiAlert.addAction(cancelAction)
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func showAlert(with title: String, message: String, okButtonTitle: String, okButtonAction: AlertActionBlock?) {
        let uiAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: okButtonAction)
        uiAlert.addAction(okAction)
        self.present(uiAlert, animated: true, completion: nil)
    }
}

extension UIViewController: UIAlertRules {
    // default defnitions available on alert rules extension
}

// MARK: - View controller Identifiers
// since using storyboard approach, it is essential to keep track of view controller id
extension UIViewController {
    enum Identifier: String {
         case AccountSetupViewController
    }
}

extension NSObject {
    class func myIdentity(methodSignature: String, lineNumber: String) -> MyIdentity {
        return MyIdentity(className: String(describing: self), callerPath: "\(methodSignature) :: \(lineNumber)")
    }
}
