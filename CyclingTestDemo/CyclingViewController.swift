//
//  CyclingViewController.swift
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/5.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

protocol CyclingDelegate: class {
    func save(altimeters: [Double], cyclingDatas: [CLLocation], cyclingGeoDatas: [CLLocation])
}

class CyclingViewController: UIViewController, CLLocationManagerDelegate {
    
    weak var delegate: CyclingDelegate?
    
    var locationManager: CLLocationManager!
    var cyclingDatas = [CLLocation]()
    var cyclingGeoDatas = [CLLocation]()
    var altimeterArray = [Double]()
    var altimeter = CMAltimeter()
    var count = 0
    
    @IBOutlet weak var altimeterLabel: UILabel!
    var currentLocation: (normal:CLLocation, geoid:CLLocation)!
    var lastLocation: (normal:CLLocation, geoid:CLLocation)!
    var altimeterValue = 0.0

    
    @IBOutlet weak var altitude: UILabel!
    
    @IBOutlet weak var speed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = 5
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 开始获取高度计数据
    func startRelativeAltitudeUpdates() {
        //判断设备支持情况
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            altimeterLabel.text = "当前设备不支持获取高度"
            return
        }
        
        //初始化并开始实时获取数据
        let queue = OperationQueue.main
        self.altimeter.startRelativeAltitudeUpdates(to: queue, withHandler: {
            (altitudeData, error) in
            //错误处理
            guard error == nil else {
                print(error!)
                return
            }
            
                //获取各个数据
                self.altimeterValue = altitudeData!.relativeAltitude.doubleValue
                let text = "高度变化: \(String(format: "%.3f", self.altimeterValue)) 米"
                print("Date:\(Date()) 高度:\(self.altimeterValue) 计数:\(self.count)")
                self.count += 1
                self.altimeterLabel.text = text
            
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let normalLocation = locations.last!
        var geoidLocation = normalLocation
        
        let geo = GeoidCalculator.defaultManager()!
        let altitudeV = normalLocation.altitude - geo.getHeightFromLat(normalLocation.coordinate.latitude, andLon: normalLocation.coordinate.longitude)
//        let altitudeV = Double(arc4random_uniform(5) + 20)
        geoidLocation = CLLocation(coordinate: normalLocation.coordinate, altitude: altitudeV, horizontalAccuracy: normalLocation.horizontalAccuracy, verticalAccuracy: normalLocation.verticalAccuracy, course: normalLocation.course, speed: normalLocation.speed, timestamp: normalLocation.timestamp)
        
        guard geoidLocation.horizontalAccuracy > 0 && geoidLocation.verticalAccuracy > 0 else {
            return
        }
        
        currentLocation = (normalLocation, geoidLocation)
        let normal = String(format: "%.3f", currentLocation.normal.altitude)
        let geoid = String(format: "%.3f", currentLocation.geoid.altitude)
        altitude.text = "normal:\(normal) geoid:\(geoid)"
        speed.text = "\(normalLocation.speed)"
        print("地位:\(geoidLocation)")
    }
    
    @IBAction func startCycling(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        altimeter.stopRelativeAltitudeUpdates()
        startRelativeAltitudeUpdates()
        resetPoint()
        setTheTimer()
    }

    @IBAction func stopCycling(_ sender: UIButton) {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        altimeter.stopRelativeAltitudeUpdates()
        deinitTimer()
        guard cyclingDatas.count > 0 else {
            return
        }
        delegate?.save(altimeters: altimeterArray, cyclingDatas: cyclingDatas, cyclingGeoDatas: cyclingGeoDatas)
        let alert = UIAlertController(title: "Stop", message: "一共有:\(cyclingDatas.count)点", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [unowned self](_) in
            self.resetPoint()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private var timer: DispatchSourceTimer?
    var pageStepTime: DispatchTimeInterval = .seconds(1)
    
    func setTheTimer() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer?.scheduleRepeating(deadline: .now(), interval: pageStepTime, leeway: .nanoseconds(1))
        var count = 0
        
        timer?.setEventHandler { [weak self] in
            if let strongleSelf = self, let _ = self?.currentLocation {
                count += 1
                if count % 60 == 0 {
                    self?.locationManager.startUpdatingLocation()
                    self?.locationManager.startMonitoringSignificantLocationChanges()
                }
                strongleSelf.savePoint()
            }
        }
        // 启动定时器
        timer?.resume()
    }
    
    func deinitTimer() {
        if let time = self.timer {
            time.cancel()
            timer = nil
        }
    }
    
    func savePoint() {
        cyclingDatas.append(currentLocation.normal)
        cyclingGeoDatas.append(currentLocation.geoid)
        altimeterArray.append(altimeterValue)
    }
    
    func resetPoint() {
        cyclingDatas.removeAll()
        cyclingGeoDatas.removeAll()
        altimeterArray.removeAll()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
