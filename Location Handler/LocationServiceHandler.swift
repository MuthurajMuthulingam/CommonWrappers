//
//  LocationServiceHandler.swift
//  TipBX
//
//  Created by Muthuraj on 15/12/16.
//  Copyright © 2016 Sanjib Chakraborty. All rights reserved.
//

import CoreLocation
import QuadratTouch
/// Class that updates the location based on accuracy.
class LocationServiceHandler: NSObject {
    
    enum LocationNotificationConstants {
        static let locationUpdateNotification = "locationUpdateNotification"
        static let locationServiceDeniedNotification = "locationServiceDeniedNotification"
        static let locationAlertNotification = "locationAlertNotification"
    }
    
    private var locationManager:CLLocationManager?
    
    /** singleton Instance of LocationServiceHandler */
    static let sharedInstance : LocationServiceHandler = {
        let instance = LocationServiceHandler()
        return instance
    }()
    
    //MARK: - Helpers
    /**
     initialization code
     @discussion : Making it private to avoid calling.
     This will instantiate data file from bundle and instantiate managedObjectContext to refer, assign persitiant store coordinator for data model
     */
    private override init() {
        super.init()
        createLocationManager()
    }
    
    /// create a Location Manager
    private func createLocationManager() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startUpdatingLocation()
        }
    }
    
    /// Check whether location services status
    ///
    /// - Returns: Bool to indicate authorization and access level of location status
    func isLocationServicesEnabled() -> Bool {
        var status = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied,.notDetermined,.restricted:
                status = false
            case .authorizedAlways, .authorizedWhenInUse:
                status = true
            }
        }
        return status
    }
    
    /// Star updating location updates
    func startLocationUpdates() {
        locationManager?.startUpdatingLocation()
    }
}

private typealias LocationManagerDelegate = LocationServiceHandler
/// Extension to handle Location Service updates
extension LocationManagerDelegate:CLLocationManagerDelegate {
    //MARK: Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            let userInfo = ["location":currentLocation]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocationNotificationConstants.locationUpdateNotification), object: nil, userInfo: userInfo)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied || status == .restricted || status == .notDetermined {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocationNotificationConstants.locationServiceDeniedNotification), object: nil)
        }
    }
}

// MARK: - extention to generate paramenters for request from location
extension CLLocation
{
    func parameters() -> Parameters
    {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc,
        ]
        return parameters
    }
}
