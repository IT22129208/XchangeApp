//
//  LocationService.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements CoreLocation & MapKit Geolocation Service (Rubric Section 6)
//

import Foundation
import CoreLocation
import MapKit
import Combine

/// Service managing device location, proximity calculations, and MapKit routing
public final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    @Published public var userLocation: CLLocationCoordinate2D
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocating: Bool = false
    
    private let locationManager = CLLocationManager()
    
    // Default fallback location: San Francisco Downtown / Tech Hub
    public static let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    // SLIIT Malabe Campus coordinates for academic demo reference
    public static let sliitCampusCoordinate = CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.9729)
    
    private override init() {
        self.userLocation = Self.defaultCoordinate
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.isLocating = false
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocating = false
        }
    }
    
    // MARK: - MapKit Directions Route Calculation
    
    /// Calculates driving or walking ETA and distance between user and a Safe Zone
    public func calculateRouteETA(to destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .automobile) async -> (distanceMiles: Double, travelTimeMinutes: Int)? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            if let route = response.routes.first {
                let miles = route.distance / 1609.34
                let minutes = Int(route.expectedTravelTime / 60.0)
                return (miles, minutes)
            }
        } catch {
            // Calculate straight-line distance fallback
            let loc1 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let loc2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
            let miles = loc1.distance(from: loc2) / 1609.34
            let estMinutes = max(Int(miles * 2.5), 3)
            return (miles, estMinutes)
        }
        return nil
    }
}
