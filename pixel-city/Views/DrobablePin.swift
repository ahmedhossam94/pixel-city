//
//  DrobablePin.swift
//  pixel-city
//
//  Created by ahmed on 1/23/18.
//  Copyright © 2018 ahmed. All rights reserved.
//

import UIKit
import MapKit
class DrobablePin: NSObject,MKAnnotation {
  dynamic  var coordinate:CLLocationCoordinate2D
    var identifier:String
    init(coordinate : CLLocationCoordinate2D,identifier :String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}
