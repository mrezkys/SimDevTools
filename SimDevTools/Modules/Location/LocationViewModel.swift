//
//  LocationViewModel.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 01/10/24.
//

import SwiftUI
import CoreLocation
import MapKit

enum LocationViewState {
    case normal
    case error
}

class LocationViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var selectedLocation: LocationModel? {
        didSet {
            if let coordinate = selectedLocation?.coordinate {
                latitude = String(format: "%.8f", coordinate.latitude)
                longitude = String(format: "%.8f", coordinate.longitude)
                
                region.center = coordinate
            }
        }
    }
    
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var message: ContentHeaderMessageModel?
    @Published var viewState: LocationViewState = .normal
    
    @Published var searchQuery: String = ""
    @Published var searchResults: [LocationSearchResultModel] = []
    private var searchTimer: Timer?
    
    
    init() {
        let initialCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        selectedLocation = LocationModel(coordinate: initialCoordinate)
        latitude = String(format: "%.8f", initialCoordinate.latitude)
        longitude = String(format: "%.8f", initialCoordinate.longitude)
    }
    
    func performSearch() {
        // Cancel any existing timer
        searchTimer?.invalidate()
         
         // Set up a new timer to delay the search
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.executeSearch()
        }
    }
    
    private func executeSearch() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.message = ContentHeaderMessageModel(text: "Search error: \(error.localizedDescription)", type: .error)
                    self?.searchResults = []
                } else if let response = response {
                    self?.searchResults = response.mapItems.map { item in
                        LocationSearchResultModel(
                            name: item.name ?? "Unknown",
                            coordinate: item.placemark.coordinate
                        )
                    }
                    self?.message = nil
                }
            }
        }
    }

    
    func selectSearchResult(_ result: LocationSearchResultModel) {
        selectedLocation = LocationModel(coordinate: result.coordinate)
        searchQuery = result.name
        searchResults = []
    }
    
    func setSimulatorLocation() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            viewState =  .error
            message = ContentHeaderMessageModel(text: "Invalid coordinates", type: .error)
            return
        }
        viewState = .normal
        runSimctlCommand(action: .setLocation(latitude: lat, longitude: lon))
    }
    
    func clearSimulatorLocation() {
        runSimctlCommand(action: .clearLocation)
    }
    
    func startSimulatedRoute() {
        let waypoints: [(Double, Double)] = [
            (37.7749, -122.4194), // San Francisco
            (34.0522, -118.2437)  // Los Angeles
        ]
        let speed = 20.0 // meters per second
        let distance = 1000.0 // meters per update
        runSimctlCommand(action: .startRoute(waypoints: waypoints, speed: speed, distance: distance))
    }
    
    private func runSimctlCommand(action: LocationActionType) {
        let process = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        
        switch action {
        case .setLocation(let latitude, let longitude):
            process.arguments = ["simctl", "location", "booted", "set", "\(latitude),\(longitude)"]
            
        case .startRoute(let waypoints, let speed, let distance):
            let waypointsString = waypoints.map { "\($0.0),\($0.1)" }.joined(separator: " ")
            process.arguments = ["simctl", "location", "booted", "start", "--speed=\(speed)", "--distance=\(distance)", waypointsString]
            
        case .clearLocation:
            process.arguments = ["simctl", "location", "booted", "clear"]
        }
        
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
        } catch {
            viewState = .error
            message = ContentHeaderMessageModel(text: "Failed to run simctl: \(error.localizedDescription)", type: .error)
            return
        }
        
        process.waitUntilExit()
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
            viewState = .error
            message = ContentHeaderMessageModel(text: "Error: \(errorOutput)", type: .error)
        } else {
            print("simctl command executed successfully")
            viewState = .normal
            message = ContentHeaderMessageModel(text: "Simulator location set successfully.", type: .success)
        }
    }
}


struct MapViewRepresentable: NSViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: LocationModel?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.region = region
        mapView.delegate = context.coordinator
        
        // Add click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClickGesture(_:)))
        mapView.addGestureRecognizer(clickGesture)
        
        return mapView
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            if nsView.region.center.latitude != region.center.latitude ||
                nsView.region.center.longitude != region.center.longitude ||
                nsView.region.span.latitudeDelta != region.span.latitudeDelta ||
                nsView.region.span.longitudeDelta != region.span.longitudeDelta {

                nsView.setRegion(region, animated: true)
            }
            
            nsView.removeAnnotations(nsView.annotations)
            
            if let selectedLocation = selectedLocation {
                let annotation = MKPointAnnotation()
                annotation.coordinate = selectedLocation.coordinate
                nsView.addAnnotation(annotation)
            }
        }
    }

    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleClickGesture(_ gestureRecognizer: NSClickGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
                if let mapView = gestureRecognizer.view as? MKMapView {
                    let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                    parent.selectedLocation = LocationModel(coordinate: coordinate)
                    
                    parent.region.center = coordinate
                }
            }
        }
    }
}
