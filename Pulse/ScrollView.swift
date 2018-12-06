//
//  ScrollView.swift
//  pulse
//
//  Created by Rob Broadwell on 12/14/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollTo(direction: ScrollDirection, animated: Bool = true) {
        self.setContentOffset(direction.contentOffsetWith(self), animated: animated)
    }
}

enum ScrollDirection {
    case top
    case right
    case bottom
    case left
    
    func contentOffsetWith(_ scrollView: UIScrollView) -> CGPoint {
        var contentOffset = CGPoint.zero
        switch self {
        case .top:
            contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        case .right:
            contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
        case .bottom:
            contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        case .left:
            contentOffset = CGPoint(x: -scrollView.contentInset.left, y: 0)
        }
        return contentOffset
    }
}


