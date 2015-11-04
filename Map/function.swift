//
//  function.swift
//  Map
//
//  Created by UCHIDAYUTA on 2015/9/10.
//  Copyright (c) 2015 YUT. All rights reserved.
//

import Foundation
import MapKit

class PublicFunctions {
    
    func FormatLocationLog(latitude: CLLocationDegrees!, longitude: CLLocationDegrees!)-> String {
        
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        let time = dateFormatter.stringFromDate(now)
        
        if latitude != nil && longitude != nil {
            return "\(time) latiitude: \(latitude) , longitude: \(longitude) \n"
        } else {
            let errMsg = "位置情報の取得に失敗しました。\n"
            return "\(time) \(errMsg)"
        }
    }
    
    func locationToMeter(latitude1: CLLocationDegrees, latitude2: CLLocationDegrees?, longitude1: CLLocationDegrees, longitude2: CLLocationDegrees?)-> uint {
        
        let latitude3 = latitude2 ?? 0.0
        let longitude3 = longitude2 ?? 0.0
        
        let meter1 = pow((latitude1 - latitude3) / 0.0111, 2.0)
        let meter2 = pow((longitude1 - longitude3) / 0.0091, 2.0)
        let meter = sqrt(meter1 + meter2) * 1000
        return UInt32(meter)
    }
}