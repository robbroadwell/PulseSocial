//
//  PulseMap.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class PulseMap: MKMapView, Map {
    
    let user = UserLocation()
    
    func addPin(key: String, location: CLLocation, score: Int) {
        if !pinExists(withKey: key) {
            
            let coordinate = location.coordinate
            let annotation = ScorePointAnnotation()
            annotation.title = key
            annotation.score = score
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.addAnnotation(annotation)
        }
    }
    
    func removePin(key: String) {
        for annotation in self.annotations {
            if let title = annotation.title {
                if title == key {
                    self.removeAnnotation(annotation)
                }
            }
        }
    }
    
    private func pinExists(withKey key: String) -> Bool {
        for pin in self.annotations {
            if let title = pin.title {
                if title == key {
                    return true
                }
            }
        }
        return false
    }
    
    func removeOffscreenPins() {
        DispatchQueue.global(qos: .default).async {
            let visible = self.annotations(in: self.visibleMapRect)
            for annotation in self.annotations {
                if !visible.contains(annotation as! AnyHashable) {
                    self.removeAnnotation(annotation)
                }
            }
        }
    }
    
    func moveToUserLocation() {
        let center = CLLocationCoordinate2D(latitude: (user.currentLatitude()), longitude: (user.currentLongitude()))
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.setRegion(region, animated: true)
    }
    
    func currentMapRegion() -> MKCoordinateRegion {
        return self.region
    }
    
    func currentUserLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: user.currentLatitude(), longitude: user.currentLongitude())
    }
}
