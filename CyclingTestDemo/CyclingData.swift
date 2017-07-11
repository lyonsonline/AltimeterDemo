//
//  CyclingData
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/7.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

final class CyclingData: NSManagedObject {
    @NSManaged fileprivate(set) var startDate: Date
    @NSManaged fileprivate(set) var endDate: Date
    @NSManaged fileprivate(set) var altimeters: [Double]
    @NSManaged fileprivate(set) var cyclingLocations: [CLLocation]
    @NSManaged fileprivate(set) var cyclingGeoLocations: [CLLocation]
    
    static func insert(into context: NSManagedObjectContext, altimeters: [Double], cyclingDatas: [CLLocation], cyclingGeoDatas: [CLLocation]) -> CyclingData {
        let cyclingData: CyclingData = context.insertObject()
        cyclingData.startDate = cyclingDatas.first!.timestamp
        cyclingData.endDate = cyclingDatas.last!.timestamp
        cyclingData.altimeters = altimeters
        cyclingData.cyclingLocations = cyclingDatas
        cyclingData.cyclingGeoLocations = cyclingGeoDatas
        return cyclingData
    }
}

extension CyclingData: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(startDate), ascending: false)]
    }
}
