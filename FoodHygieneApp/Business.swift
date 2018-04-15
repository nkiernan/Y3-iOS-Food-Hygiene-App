//
//  Business.swift
//  FoodHygieneApp
//
//  Created by Nathan Kiernan on 15/03/2018.
//  Copyright © 2018 Nathan Kiernan. All rights reserved.
//

import Foundation

// Codable to automatically deserialise JSON and create object(s) of this class
class Business: Codable {
    let id: String
    let BusinessName: String
    let AddressLine1: String
    let AddressLine2: String?
    let AddressLine3: String?
    let PostCode: String
    let RatingValue: String
    let RatingDate: String
    let Longitude: String
    let Latitude: String
    let DistanceKM: String?
}
