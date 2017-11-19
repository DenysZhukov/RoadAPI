//
//  Services.swift
//  RoadAPI
//
//  Created by Denys on 11/19/17.
//  Copyright © 2017 Denys Zhukov. All rights reserved.
//

import Foundation
import GoogleMaps

class Services {
    
    private let googleAPIKey = "AIzaSyAXtwmu8yzYvTDsdAS1JjcNaqrOasWRemk"
    
    func configure() {
       GMSServices.provideAPIKey(googleAPIKey)
    }
}
