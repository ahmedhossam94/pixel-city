//
//  Constants.swift
//  pixel-city
//
//  Created by ahmed on 1/25/18.
//  Copyright © 2018 ahmed. All rights reserved.
//

import Foundation
let apiKey = "Your key"
//let key = "17f7598123d6e923150d99a449464c05" Maybe expire
func flickUrl(forApiKey key: String , withAnnotation annotation:DrobablePin , andNumberOfPhotes number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mil&per_page=\(number)&format=json&nojsoncallback=1"
    
    
}

//https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=17f7598123d6e923150d99a449464c05&lat=42.8&lon=122.3&radius=1&radius_units=mil&per_page=40&format=json&nojsoncallback=1
