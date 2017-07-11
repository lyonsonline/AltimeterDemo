//
//  RootTableViewController.swift
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/5.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class RootTableViewController: UITableViewController {

    var dataArray = Array<CLLocation>()
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private
    
    fileprivate var dataSource: TableViewDataSource<RootTableViewController>!
    fileprivate var observer: ManagedObjectObserver?
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        let request = CyclingData.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "Cell", fetchedResultsController: frc, delegate: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case "Charts":
            let chartsVC = segue.destination as! ChartsViewController
            chartsVC.cyclingData = dataSource.selectedObject
        case "Cycling":
            let cyclingVC = segue.destination as! CyclingViewController
            cyclingVC.delegate = self
        default:
            break
        }
    }
}
extension RootTableViewController: TableViewDataSourceDelegate {
    func configure(_ cell: TableViewCell, for object: CyclingData) {
        cell.config(object: object)
    }
}
extension RootTableViewController: CyclingDelegate {
    func save(altimeters: [Double], cyclingDatas: [CLLocation], cyclingGeoDatas: [CLLocation]) {
        managedObjectContext.performChanges {
            _ = CyclingData.insert(into: self.managedObjectContext, altimeters: altimeters, cyclingDatas: cyclingDatas, cyclingGeoDatas: cyclingGeoDatas)
        }
    }
}
