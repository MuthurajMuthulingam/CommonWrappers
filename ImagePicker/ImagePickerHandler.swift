//
//  ImagePickerHandler.swift
//  TipBX
//
//  Created by Muthuraj on 26/09/16.
//  Copyright © 2016 Sanjib Chakraborty. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import MobileCoreServices

/// Class that picks or loads the images from Camera/Gallery.
class ImagePickerHandler: NSObject {
    
    private enum PickerSourceType: Int{
        case sourceGallery = 0
        case sourceCamera
    }
    
    var viewController:UIViewController?
    
    private var imagePicker =  UIImagePickerController()
    // completion Block
    var selectedImageBlock:((_ selectedImage:UIImage?) -> (Void))?
    
    // MARK: - Heleper methods
    //Shows ActionSheet
    private func showActionSheet(){
        let actionSheet = ActionSheet.createActionSheet(title:nil, message: nil, buttonTitles: LocaliseStrings.actionSheetSourceTypeGallery.localized(), LocaliseStrings.actionSheetSourceTypeCamera.localized(), LocaliseStrings.actionSheetCloseButton.localized(), destructiveButtonIndex: Int.Constants.minusOne.value(), cancelButtonIndex: SignupVCConstants.actionSheetCancelButtonIndex, actionSheetButtonTapBlock: {  [weak self] (sourceType: Int) in
            if(self == nil) {
                return
            }
            self?.setUpImagePickerView(sourceType: sourceType)
        })
        self.viewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    //ImagePicker InitialSetUp
    private func setUpImagePickerView(sourceType: Int) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        switch(sourceType){
        case PickerSourceType.sourceGallery.rawValue:
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.viewController?.present((self.imagePicker), animated: true, completion: nil)
            
            break
        case PickerSourceType.sourceCamera.rawValue:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                showCamera()
            }
            else{
                let alertView = AlertView.createAlertView(title: LocaliseStrings.alertViewTitle.localized(), message: LocaliseStrings.alertViewCameraNotFoundMessage.localized(), buttonTitles: LocaliseStrings.okButton.localized(), destructiveButtonIndex: Int.Constants.minusOne.value(), cancelButtonIndex: Int.Constants.zero.value(), alertViewButtonTapBlock: nil)
                self.viewController?.present(alertView, animated: true, completion: nil)
                
            }
            break
        default: break
        }
    }
    
    //Method to show Camera if has access.
    private func showCamera(){
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch(authStatus){
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] (granted:Bool) in
                if(self == nil){
                    return
                }
                if(granted){
                    self?.imagePicker.sourceType = .camera
                    self?.imagePicker.mediaTypes = [kUTTypeImage as String]
                    self?.viewController?.present((self?.imagePicker)!, animated: true, completion: nil)
                }
                else{
                    //Add Alert
                    let alertView = AlertView.createAlertView(title: LocaliseStrings.alertViewTitle.localized(), message: LocaliseStrings.alertViewCameraAuthrizationStatus.localized(), buttonTitles: LocaliseStrings.okButton.localized(), destructiveButtonIndex: Int.Constants.minusOne.value(), cancelButtonIndex: Int.Constants.zero.value(), alertViewButtonTapBlock: nil)
                    self?.viewController?.present(alertView, animated: true, completion: nil)
                }
            })
            break
        case AVAuthorizationStatus.denied:
            let alertView = AlertView.createAlertView(title: LocaliseStrings.alertViewTitle.localized(), message: LocaliseStrings.alertViewCameraAuthrizationStatus.localized(), buttonTitles: LocaliseStrings.okButton.localized(), destructiveButtonIndex: Int.Constants.minusOne.value(), cancelButtonIndex: Int.Constants.zero.value(), alertViewButtonTapBlock: nil)
            self.viewController?.present(alertView, animated: true, completion: nil)
            break
        default:
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.viewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    // Present Action sheet and Initiate Image picker
    func present() {
        showActionSheet()
    }
}
extension ImagePickerHandler {
    // call this initializer to setup ImagePicker controller
    convenience init(viewController:UIViewController) {
        self.init()
        self.viewController = viewController
    }
}

//MARK:- UIImagePicker Delegate methods.
private typealias ImagePickerControllerDelegate = ImagePickerHandler
extension ImagePickerControllerDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let completionBlock = selectedImageBlock {
            DispatchQueue.main.async {
                completionBlock(image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if let completionBlock = selectedImageBlock {
            completionBlock(nil)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
