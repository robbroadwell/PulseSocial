//
//  TimeAgo.swift
//  pulse
//
//  Created by Rob Broadwell on 12/14/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

func timeAgoSinceDate(unix: Float) -> (string: String, isRecent: Bool) {
    let date = NSDate(timeIntervalSince1970: TimeInterval(unix))
    return timeAgoSinceDate(date: date, numericDates: true)
}

// TODO: Make this safe
func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> (String, Bool) {
    
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    
    let components = calendar.dateComponents(unitFlags, from: earliest as Date, to: latest as Date!)
    
    // YEARS AGO
    if (components.year! >= 2) {
        return ("\(components.year!) years ago", false)
    } else if (components.year! >= 1){
        if (numericDates){
            return ("1 year ago", false)
        } else {
            return ("Last year", false)
        }
        
    // MONTHS AGO
    } else if (components.month! >= 2) {
        return ("\(components.month!) months ago", false)
    } else if (components.month! >= 1){
        if (numericDates){
            return ("1 month ago", false)
        } else {
            return ("Last month", false)
        }
        
    // WEEKS AGO
    } else if (components.weekOfYear! >= 2) {
        return ("\(components.weekOfYear!) weeks ago", false)
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return ("1 week ago", false)
        } else {
            return ("Last week", false)
        }
        
    // DAYS AGO
    } else if (components.day! >= 2) {
        return ("\(components.day!) days ago", false)
    } else if (components.day! >= 1){
        if (numericDates){
            return ("1 day ago", false)
        } else {
            return ("Yesterday", false)
        }
    } else if (components.hour! >= 2) {
        return ("\(components.hour!) hours ago", true)
    } else if (components.hour! >= 1){
        if (numericDates){
            return ("1 hour ago", true)
        } else {
            return ("An hour ago", true)
        }
    } else if (components.minute! >= 2) {
        return ("\(components.minute!) minutes ago", true)
    } else if (components.minute! >= 1){
        if (numericDates){
            return ("1 minute ago", true)
        } else {
            return ("A minute ago", true)
        }
    } else if (components.second! >= 3) {
        return ("\(components.second!) seconds ago", true)
    } else {
        return ("Just now", true)
    }
    
}
