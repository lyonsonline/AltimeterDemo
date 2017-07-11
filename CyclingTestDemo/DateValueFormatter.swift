//
//  DateValueFormatter.swift
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/5.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit
import Charts

class DateValueFormatter: NSObject, IAxisValueFormatter {
    
    var dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }

}
