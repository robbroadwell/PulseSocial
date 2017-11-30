//
//  UserLocation.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var map: Map?
    var launchLocationSet = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation = CLLocation()
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last! as CLLocation!
        if !launchLocationSet {
            map?.moveToUserLocation()
            launchLocationSet = true
        }
    }
    
    func currentLatitude() -> CLLocationDegrees {
        return currentLocation.coordinate.latitude
    }
    
    func currentLongitude() -> CLLocationDegrees {
        return currentLocation.coordinate.longitude
    }
}
