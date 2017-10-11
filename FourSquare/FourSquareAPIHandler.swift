//
//  FourSquareAPIHandler.swift
//  TipBX
//
//  Created by Muthuraj on 09/12/16.
//  Copyright © 2016 Sanjib Chakraborty. All rights reserved.
//

import QuadratTouch
import CoreLocation
/// Class that gets the Venus from FourSquare API and Parses it.
class FourSquareAPIHandler: NSObject {
    
    typealias venuesList = ((_ venues:[[String: AnyObject]]) -> (Void))
    
    /// singleton Instance of FourSquare Helper
    static let sharedInstance : FourSquareAPIHandler = {
        let instance = FourSquareAPIHandler()
        return instance
    }()
    
    var session:Session?
    
    /// to avoid calling init method
    private override init() {
        super.init()
        // Initialize the Foursquare client
        // TODO: update Client ID and Client Secret with actual premium account, personal account used for testing
        let client = Client(clientID: "VV2001J13RM4C2PKBPHQOIVIMDFIYTFM4I0D5OTPL33GN0QB", clientSecret: "HYBKJD20NTZLKEQXJEYTYDKANO2WL2IAG3AWAEH34HVV1EF3", redirectURL: "")
        
        let configuration = Configuration(client:client)
        Session.setupSharedSessionWithConfiguration(configuration)
        self.session = Session.sharedSession()
    }
    
    // MARK: - Helpers
    /**
     Get Nearby locations.
     @discussion: Get all nearby location matching search query.
     */
    func getNearbyVenus(_ location:CLLocation,searchQuery:String?, completion:venuesList?){
        if let session = self.session
        {
            // Provide the user location and the hard-coded Foursquare category ID for "Coffeeshops"
            var parameters = location.parameters()

            // Add sorting and intent
            parameters += [Parameter.sortByDistance:"1"]
            
            if let searchTerm = searchQuery {
                parameters += [Parameter.query: searchTerm]
            }
            
            // Start a "search", i.e. an async call to Foursquare that should return venue data
            let searchTask = session.venues.search(parameters)
            {
                (result) -> Void in
                
                if let response = result.response
                {
                    if let venues = response["venues"] as? [[String: AnyObject]]
                    {
                        // sort the result from Foursquare by distance, since sorting is not done from server
                        let sortedVenues = venues.sorted {
                            item1, item2 in
                            if let distance1 = item1["location"]?["distance"] as? Double ,
                                let distance2 = item2["location"]?["distance"] as? Double {
                                return distance1 < distance2
                            }
                            return false
                        }
                        if let completionBlock = completion {
                            completionBlock(sortedVenues)
                        }
                    }
                }
            }
            
            searchTask.start()
        }
    }
}
