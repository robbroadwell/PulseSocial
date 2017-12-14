//
//  Public.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase
import UIKit

public var uid: String { return Auth.auth().currentUser!.uid }
public var timestamp: TimeInterval { return NSDate().timeIntervalSince1970 }
public var screenWidth: CGFloat { return UIScreen.main.bounds.width }
public var screenHeight: CGFloat { return UIScreen.main.bounds.height }
