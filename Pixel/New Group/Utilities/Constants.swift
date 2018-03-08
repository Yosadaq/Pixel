//
//  Constants.swift
//  Pixel
//
//  Created by Yosadaq Esparza on 3/1/18.
//  Copyright © 2018 Y.M. All rights reserved.
//

import Foundation

let apiKey = "32a6fc6319ba774ee2673a1cdf7cd516"

func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}
