//
//  LocationSearchResultModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 02/10/24.
//

import Foundation
import MapKit

struct LocationSearchResultModel: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
