//
//  CyclingStack
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/7.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import CoreData

func createCyclingContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    let container = NSPersistentContainer(name: "Cycling")
    container.loadPersistentStores { _, error in
        guard error == nil else { fatalError("Failed to load store: \(String(describing: error))") }
        DispatchQueue.main.async { completion(container) }
    }
}
