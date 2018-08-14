//
//  NetworkService+Utilities.swift
//  Entrada
//
//  Created by Muthuraj Muthulingam on 06/08/18.
//  Copyright © 2018 Entrada, Inc. All rights reserved.
//

import Foundation

enum NGMEnvironment {
     case prod
     case dev
     case stage
     case qa1
     case qa2
     case qa3
     case sales
    
    var urlString: String {
        var currentURLString: String = ""
        switch self {
        case .dev, .qa1, .qa2, .stage, .qa3:
            currentURLString = "https://apidev.nextgen.com" // dev URL
        case .prod, .sales:
            // TODO : Update PROD URL
            currentURLString = "https://apidev.nextgen.com" // prod URL
        }
        return currentURLString
    }
}

class API {
    // shared instance
    static let shared: API = API()
    
    var baseURLString: String = NGMEnvironment.dev.urlString
    private var environment: NGMEnvironment = .dev {
        didSet {
            // update base URL
            baseURLString = environment.urlString
        }
    }
    
    func setEnvironment(environment: NGMEnvironment) {
        self.environment = environment // this updates base url string
    }
}
