//
//  Place.swift
//  MapRoutes (iOS)
//
//  Created by Michele Manniello on 01/11/21.
//

import SwiftUI
import MapKit
struct Place: Identifiable {
    var id = UUID().uuidString
    var placemark: CLPlacemark
}
