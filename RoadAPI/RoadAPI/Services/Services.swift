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
    
    private let googleAPIKey = "AIzaSyCE0ZVytP96wIWjJMz9NONwzVqjxGTrY_A"
    
    func configure() {
       GMSServices.provideAPIKey(googleAPIKey)
    }
}
