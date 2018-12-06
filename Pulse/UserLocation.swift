//
//  UserLocation.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import CoreLocation

var userLocation: UserLocation?

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var launchLocationSet = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    public var currentLocation: CLLocation!
    
    private var locationManager = CLLocationManager()
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last! as CLLocation!
        if !launchLocationSet {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLocation"), object: nil, userInfo: nil)
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
