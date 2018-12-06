//
//  PulseMap.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import MapKit

class PulseMapView: MKMapView {
    
    func addPin(key: String, location: CLLocation) {
        if !pinExists(withKey: key) {
            
            let coordinate = location.coordinate
            let annotation = MKPointAnnotation()
            annotation.title = key
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
    
    func moveTo(location: CLLocation, animated: Bool = true, spanDelta: CLLocationDegrees = 1) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta))
        self.setRegion(region, animated: animated)
    }
    
    func currentMapRegion() -> MKCoordinateRegion {
        return self.region
    }
}
