//
//  AWSIoTHandler.swift
//
//  Created by Muthuraj on 13/12/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit
import AWSIoT

/**
 Public struct to represent User Location
 */
/// Struct to store UserLocation properties
struct UserLocation {
    var latitude:String!
    var longitude:String!
    var userId:String!
    var orgId:String?
    
    /// convert UserLocation to NSDictionary
    ///
    /// - Returns: returns a dictionary from UserLocation instance
    func getDict() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setObject(latitude, forKey: "latitude" as NSCopying)
        dict.setObject(longitude, forKey: "longitude" as NSCopying)
        dict.setObject(userId, forKey: "userId" as NSCopying)
        if let organizationalID = orgId {
            dict.setObject(organizationalID, forKey: "orgId" as NSCopying)
        }
        return dict
    }
    
    /// convert to JSON Data
    ///
    /// - Returns: returns a JSON Data from UserLocation
    func getJSON() -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: getDict(), options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
            
        } catch _ as NSError {
            // Error
            return nil
        }
    }
}

/**
 * Constants related to AWS IOT SDK
 */
/// Struct to represent constants used inside AWSHandler
struct AWSConstants {
    static let region = AWSRegionType.usWest2//"us-west-2"
    static let cognitoIdentityPoolId = "POOL ID"
    static let certificateSigningRequestCommonName = "YOUR App"
    static let certificateSigningRequestCountryName = "US"
    static let certificateSigningRequestOrganizationName = "YOUR APP NAME"
    static let certificateSigningRequestOrganizationalUnitName = "YOUR APP NAME"
    static let policyName = "YOURAPP-ios-app-policy"
    static let certificatePassword = "PASSWORD"
    static let PKCS12FileExtension = "p12"
    static let certificateARN = "from-bundle"
    
    // topics
    enum Topics : String{
        // YOUR TOPICS INTERESTED
        
        func string() -> String{
            return rawValue
        }
    }
}

/**
 * Class to handle AWS IoT Connections
 * Subscribe/Publish MQTT Topics
 * Broadcast a notification about connection status
 * unsubscribe Topics if unneeded.
 */

class AWSIoTHandler: NSObject {
    
    /// Struct to represent certificate details
    private struct Certificate {
        var ID:Data!
        var ARN:String = "from-bundle"
        var Path:String!
    }
    
    typealias statusBlock = ((_ status:Bool) -> (Void))
    
    private var iotDataManager:AWSIoTDataManager?
    /// Flag to know connectivity
    var isConnected:Bool = false
    
    /// Shared Instance of AWSIoT Handler
    static let sharedInstance = AWSIoTHandler.init()
    
    /**
     @discussion:  to avoid calling from external classes.
     */
    private override init() {
        super.init()
        configuareAWSIoT()
        // call it once the instance updated
        instantiateCommonAWSIoTInstances()
    }
    
    //MARK: - Public Methods
    /**
     * Connect to AWSIoT Server through certificate
     * @discuission: we are tried using websocket approach, but it returns unexpected errors, hence try with certificate approach instead.
     */
    func connectToAWSIoT(_ usingClientID:String, _ completion:statusBlock?) {
        
        // MQTT call back
        func mqttEventCallback( status: AWSIoTMQTTStatus, compeltion:statusBlock?){
            DispatchQueue.main.async {
                switch(status) {
                case .connecting: break
                case .connected:
                    self.isConnected = true
                    break
                case .disconnected: break
                case .connectionRefused,.connectionError,.protocolError: break
                default: break
                }
                if let completionBlock = compeltion {
                    completionBlock(self.isConnected)
                }
            }
        }
        
        if let certificate = readCertificateFromUserDefault() {
            // using certificate id
            iotDataManager?.connect(withClientId: usingClientID, cleanSession: true, certificateId: certificate.Path, statusCallback: { (_ status:AWSIoTMQTTStatus) in
                mqttEventCallback(status: status, compeltion: completion)
            })
            // using web socket
            //iotDataManager?.connectUsingWebSocket(withClientId: uuid, cleanSession: true, statusCallback: mqttEventCallback)
        } else {
            if let certificate = getCertificate() {
                if store(certificate: certificate){
                    // using certificate id
                    iotDataManager?.connect(withClientId: usingClientID, cleanSession: true, certificateId: certificate.Path, statusCallback: { (_ status:AWSIoTMQTTStatus) in
                        mqttEventCallback(status: status, compeltion: completion)
                    })
                    // using websocket
                    //iotDataManager?.connectUsingWebSocket(withClientId: uuid, cleanSession: true, statusCallback: mqttEventCallback)
                }
            } else {
            }
        }
    }
    
    /// will disconnect from AWSIoT server
    func disConnect() {
        self.iotDataManager?.disconnect()
    }
    
    /// making new subscribtion from AWSIoT
    ///
    /// - Parameters:
    ///   - topicName: name of Topic to which subscribtion will happen
    ///   - completionHandler: handler to inform about status of subscription
    func subscribe(toTopic topicName: String , completionHandler: @escaping (_ status:Bool,_  data:[String:AnyObject]?) -> Void) {
        
        iotDataManager?.subscribe(toTopic: topicName, qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: { (data:Data?) in
            if let dataValue = data {
                // Now you just need to decode it
                //sanjumili
                do {
                    if let responseObject = try JSONSerialization.jsonObject(with: dataValue, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:AnyObject] {
                        completionHandler(true, responseObject)
                    } else {
                        completionHandler(false, nil)
                    }
                } catch _ as NSError {
                    completionHandler(false, nil)
                }
            }
        })
    }
    
    /// unSubscribing topic from AWSIoT server
    ///
    /// - Parameter topicName: name of the topic to be unsubscribed
    func unSubscribeToTopic(topicName : String){
        iotDataManager?.unsubscribeTopic(topicName)
    }
    
    /// publish information to AWSIoT on specific MQTT Topic
    ///
    /// - Parameters:
    ///   - location: user location details to be shared as message
    ///   - onTopic: topic on which information to be published
    /// - Returns: returns a status
    func publish(location:UserLocation, onTopic:String) -> Bool {
        var status = false
            if let data = location.getJSON() {
                if let result = iotDataManager?.publishData(data, onTopic: onTopic, qoS: .messageDeliveryAttemptedAtLeastOnce) {
                    status = result
                }
            }
        return status
    }
    
    //MARK: - Helpers
    /**
     * This will configuare AWSService for initial use.
     * Best place to call, as soon as app launches, i.e, from Appdelegate
     */
    private func configuareAWSIoT() {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSConstants.region, identityPoolId: AWSConstants.cognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AWSConstants.region,credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    /// configuare default instances, i.e AWTIoTDataManagers,AWSIoTManager, etc
    private func instantiateCommonAWSIoTInstances() {
        iotDataManager = AWSIoTDataManager.default()
    }
    /// get certificate from PKCS12 file stored inside app bundle
    private func getCertificate() -> Certificate? {
        let certificateData = Bundle.main.paths(forResourcesOfType: AWSConstants.PKCS12FileExtension, inDirectory:nil)
        
        if (certificateData.count > 0) {
            //
            // At least one PKCS12 file exists in the bundle.  Attempt to load the first one
            // into the keychain (the others are ignored), and set the certificate ID in the
            // user defaults as the filename.  If the PKCS12 file requires a passphrase,
            // you'll need to provide that here; this code is written to expect that the
            // PKCS12 file will not have a passphrase.
            //
            if let data = NSData(contentsOfFile:certificateData[0]) {
                if AWSIoTManager.importIdentity(fromPKCS12Data: data as Data!, passPhrase:AWSConstants.certificatePassword, certificateId:certificateData[0]) {
                    return Certificate(ID: data as Data!, ARN: AWSConstants.certificateARN, Path: certificateData[0])
                }
            }
        }
        return nil
    }
    
    /// store Certificate details to UserDeafults
    private func store(certificate: Certificate) -> Bool {
        UserDefaults.standard.set(certificate.ID, forKey: String.Constants.AWSIOT.certificateID.string())
        UserDefaults.standard.set(certificate.ARN, forKey: String.Constants.AWSIOT.certificateARN.string())
        let status = UserDefaults.standard.synchronize()
        return status
    }
    
    /// get Certificate from User Defaults
    private func readCertificateFromUserDefault() -> Certificate? {
        if let certificateID = UserDefaults.standard.value(forKey: String.Constants.AWSIOT.certificateID.string()) as? Data,
            let certificateARN = UserDefaults.standard.value(forKey: String.Constants.AWSIOT.certificateARN.string()) as? String,
            let certificatePath = UserDefaults.standard.value(forKey: String.Constants.AWSIOT.cetitificatePath.string()) as? String{
            return Certificate(ID: certificateID, ARN: certificateARN,Path: certificatePath)
        }
        return nil
    }
}
