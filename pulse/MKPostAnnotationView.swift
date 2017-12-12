//
//  MKPostAnnotationView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import MapKit

/** CustomCalloutAnnotationView
 
 This is a MKAnnotationView that will resize to fit a annotationBackground. This is crucial if the annotation view is going to have a custom callout because otherwise any touches inside the custom callout will not be recognized as withing the annotation view but rather only on the underlying view.
 */
class MKPostAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // TODO: Adjust based on score
    
        let pin = ScorePin.instanceFromNib()
        
        if let custom = annotation as? MKPostAnnotation {
            pin.label.text = String(custom.post.score)
        }
        
        self.contain(view: pin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
