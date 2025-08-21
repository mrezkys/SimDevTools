//
//  LocationActionType.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import Foundation
import CoreLocation

enum LocationActionType {
    case setLocation(latitude: Double, longitude: Double)
    case startRoute(waypoints: [(latitude: Double, longitude: Double)], speed: Double, distance: Double?)
    case clearLocation
}
