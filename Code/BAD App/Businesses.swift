//
//  Businesses.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 4/4/16.
//  Copyright © 2016 Cody and Dalton Senior Project. All rights reserved.
//

import Foundation

class Business {
    let name:String
    let latitude:String
    let longitude:String
    let address:String
    let category:String
    let type:String
    let phone:String
    let website:String
    let description:String
    
    
    init(name:String, latitude:String, longitude:String, address:String, category:String, type:String, phone:String, website:String, description:String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.category = category
        self.type = type
        self.phone = phone
        self.website = website
        self.description = description

    }
    
}