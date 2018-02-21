//
//  DroppablePin.swift
//  Pixel
//
//  Created by Yosadaq Esparza on 2/21/18.
//  Copyright © 2018 Y.M. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin: NSObject, MKAnnotation {
   dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
