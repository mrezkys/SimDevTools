//
//  LocationModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import Foundation
import CoreLocation

struct LocationModel: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
