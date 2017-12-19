//
//  PushNoAnimationSegue.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class PushNoAnimationSegue: UIStoryboardSegue {
    
    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
}
