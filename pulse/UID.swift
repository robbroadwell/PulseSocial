//
//  UID.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase

public var uid: String {
    return Auth.auth().currentUser!.uid
}
