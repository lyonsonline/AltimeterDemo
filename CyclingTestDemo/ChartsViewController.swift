//
//  ChartsViewController.swift
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/5.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit
import Charts
import CoreLocation
var max = 2.5
var min = 0.5
class ChartsViewController: UIViewController, ChartViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var totalClimbDistance: UILabel! //累计爬升
    @IBOutlet weak var climbDistance: UILabel! //爬坡距离
    @IBOutlet weak var distance: UILabel! //骑行距离
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var maxValue: UITextField!
    @IBOutlet weak var minValue: UITextField!
    
    var cyclingData: CyclingData!
    var showNormal = true {
        didSet {
            if showNormal {
                normalBtn.setTitle("显示Normal", for: .normal)
            } else {
                normalBtn.setTitle("隐藏Normal", for: .normal)
            }
        }
    }
    var showGeo = true {
        didSet {
            if showGeo {
                geoBtn.setTitle("显示Geo", for: .normal)
            } else {
                geoBtn.setTitle("隐藏Geo", for: .normal)
            }
        }
    }
    var showAltimeter = true {
        didSet {
            if showAltimeter {
                altimeterBtn.setTitle("显示Altimerter", for: .normal)
            } else {
                altimeterBtn.setTitle("隐藏Altimerter", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var altimeterBtn: UIButton!

    @IBOutlet weak var normalBtn: UIButton!
    @IBOutlet weak var geoBtn: UIButton!
    @IBAction func showNormalChart(_ sender: UIButton) {
        showNormal = !showNormal
    }
    @IBAction func showGeoChart(_ sender: UIButton) {
        showGeo = !showGeo
    }
    @IBAction func showAltimeterChart(_ sender: UIButton) {
        showAltimeter = !showAltimeter
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minValue.delegate = self
        maxValue.delegate = self
        minValue.placeholder = "\(min)"
        maxValue.placeholder = "\(max)"
        
        lineChartView.delegate = self
        lineChartView.dragEnabled = true
        lineChartView.chartDescription?.enabled = false
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.setScaleEnabled(true)
        
        lineChartView.legend.enabled = false
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawZeroLineEnabled = false
        leftAxis.axisMinimum = 0
        
        lineChartView.rightAxis.enabled = false
        
        let xAxis = lineChartView.xAxis
        xAxis.enabled = true
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.labelTextColor = UIColor.black
        xAxis.drawGridLinesEnabled = true
        xAxis.valueFormatter = DateValueFormatter()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DrawChart(_ sender: UIButton) {
        guard cyclingData.cyclingLocations.count > 0 else {
            let alert = UIAlertController(title: "Error", message: "数据为空", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            return
        }
        updateChartsData()
    }
    
    func updateChartsData() {
        if lineChartView.data != nil && lineChartView.data!.dataSetCount > 0 {
            lineChartView.clearValues()
            lineChartView.data?.notifyDataChanged()
            lineChartView.notifyDataSetChanged()
        }
        var normalTuple = setNormalLineChart1()
        var geoidTuple = setGeoidLineChart2()
        let altimeterTuple = setAltimeterLineChart2()
        let data: LineChartData?
        if showNormal {
            if showGeo {
                normalTuple.0.append(contentsOf: geoidTuple.0)
            }
            if showAltimeter {
                normalTuple.0.append(contentsOf: altimeterTuple.0)
            }
            data = LineChartData(dataSets: normalTuple.0)
        } else {
            if showGeo {
                if showAltimeter {
                    geoidTuple.0.append(contentsOf: altimeterTuple.0)
                }
                data = LineChartData(dataSets: geoidTuple.0)
            } else {
                if showAltimeter {
                    data = LineChartData(dataSets: altimeterTuple.0)
                } else {
                    data = nil
                }
            }
        }
        lineChartView.data = data
        totalClimbDistance.text = "Nor:\(normalTuple.1)\nGeo:\(geoidTuple.1)\nAlt:\(altimeterTuple.1)"
        distance.text = "Nor:\(normalTuple.2)\nGeo:\(geoidTuple.2)\nAlt:\(altimeterTuple.2)"
        climbDistance.text = "Nor:\(normalTuple.3)\nGeo:\(geoidTuple.3)\nAlt:\(altimeterTuple.3)"
    }
    
    func setNormalLineChart1() -> ([LineChartDataSet], Int, Int, Int) {
        var yVals1 = Array<ChartDataEntry>()
        var yVals1Arr = Array<Array<ChartDataEntry>>()
        
        var lastLocation: CLLocation!
        var currentLocation: CLLocation!
        var totalDistanceV: CLLocationDistance = 0.0
        var totalClimbDistanceV: CLLocationDistance = 0.0
        var climbDistanceV: CLLocationDistance = 0.0
        var lastData: ChartDataEntry = ChartDataEntry()
        var currentData: ChartDataEntry = ChartDataEntry()
        var xValue = cyclingData.cyclingLocations[0].timestamp.timeIntervalSince1970
        
        for index in 0..<cyclingData.cyclingLocations.count {
            currentLocation = cyclingData.cyclingLocations[index]
            currentData = ChartDataEntry(x: xValue, y: currentLocation.altitude)
            xValue += 1
            yVals1.append(currentData) //记录所有点
            
            if index != 0  {
                totalDistanceV += currentLocation.distance(from: lastLocation)
                let altitudeValue = currentLocation.altitude - lastLocation.altitude
                if altitudeValue > min && altitudeValue < max {
                    climbDistanceV += currentLocation.distance(from: lastLocation)//爬坡距离
                    totalClimbDistanceV += altitudeValue //累计爬升距离
                    var yVals2 = Array<ChartDataEntry>()
                    yVals2.append(lastData)
                    yVals2.append(currentData) //记录上升点
                    yVals1Arr.append(yVals2)
                }
            }
            lastLocation = currentLocation
            lastData = currentData
        }
        
        let set1: LineChartDataSet
        var set2Arr = [LineChartDataSet]()
        set1 = LineChartDataSet(values: yVals1, label: "所有点")
        set1.axisDependency = .left
        set1.colors = [UIColor(red:0.51, green:0.98, blue:0.45, alpha:1.00)]
        set1.circleColors = [UIColor.white]
        set1.circleRadius = 3.0
        set1.lineWidth = 2.0
        set1.fillAlpha = 65/255.0
        set1.fillColor = UIColor(red:0.51, green:0.98, blue:0.45, alpha:1.00)
        set1.drawCircleHoleEnabled = false
        
        for index in 0..<yVals1Arr.count {
            let set2 = LineChartDataSet(values: yVals1Arr[index], label: "上升点")
            set2.axisDependency = .left
            set2.colors = [UIColor(red:0.57, green:0.53, blue:0.98, alpha:1.00)]
            set2.drawCirclesEnabled = false
//            set2.circleColors = [UIColor.white]
//            set2.circleRadius = 3.0
            set2.lineWidth = 2.0
            set2.fillAlpha = 65/255.0
            set2.fillColor = UIColor.red
//                UIColor(red:0.57, green:0.53, blue:0.98, alpha:1.00)
            set2.drawCircleHoleEnabled = false
//            let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
//                                  ChartColorTemplates.colorFromString("#ffff0000").cgColor]
//            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            set2.fillAlpha = 0.5
//            set2.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            set2.drawFilledEnabled = true
            set2Arr.append(set2)
        }
        set2Arr.insert(set1, at: 0)
        return (set2Arr, Int(totalClimbDistanceV), Int(totalDistanceV), Int(climbDistanceV))
    }
    
    func setGeoidLineChart2() -> ([LineChartDataSet], Int, Int, Int) {
        var yVals1 = Array<ChartDataEntry>()
        var yVals1Arr = Array<Array<ChartDataEntry>>()
        
        var lastLocation: CLLocation!
        var currentLocation: CLLocation!
        var totalDistanceV: CLLocationDistance = 0.0
        var totalClimbDistanceV: CLLocationDistance = 0.0
        var climbDistanceV: CLLocationDistance = 0.0
        var lastData: ChartDataEntry = ChartDataEntry()
        var currentData: ChartDataEntry = ChartDataEntry()
         var xValue = cyclingData.cyclingLocations[0].timestamp.timeIntervalSince1970
        
        for index in 0..<cyclingData.cyclingGeoLocations.count {
            currentLocation = cyclingData.cyclingGeoLocations[index]
            currentData = ChartDataEntry(x: xValue, y: currentLocation.altitude)
            xValue += 1
            yVals1.append(currentData) //记录所有点
            
            if index != 0  {
                totalDistanceV += currentLocation.distance(from: lastLocation)
                let altitudeValue = currentLocation.altitude - lastLocation.altitude
                if altitudeValue > min && altitudeValue < max {
                    climbDistanceV += currentLocation.distance(from: lastLocation)//爬坡距离
                    totalClimbDistanceV += altitudeValue //累计爬升距离
                    var yVals2 = Array<ChartDataEntry>()
                    yVals2.append(lastData)
                    yVals2.append(currentData) //记录上升点
                    yVals1Arr.append(yVals2)
                }
            }
            lastLocation = currentLocation
            lastData = currentData
        }
        
        let set1: LineChartDataSet
        var set2Arr = [LineChartDataSet]()
        set1 = LineChartDataSet(values: yVals1, label: "所有点")
        set1.axisDependency = .left
        set1.colors = [UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)]
        set1.circleColors = [UIColor.black]
        set1.circleRadius = 2.0
        set1.lineWidth = 2.0
        set1.fillAlpha = 65/255.0
        set1.fillColor = UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)
        set1.drawCircleHoleEnabled = false
        
        for index in 0..<yVals1Arr.count {
            let set2 = LineChartDataSet(values: yVals1Arr[index], label: "上升点")
            set2.axisDependency = .left
            set2.colors = [UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)]
            set2.drawCirclesEnabled = false
//            set2.circleColors = [UIColor.white]
//            set2.circleRadius = 3.0
            set2.lineWidth = 2.0
            set2.fillAlpha = 65/255.0
            set2.fillColor = UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)
            set2.drawCircleHoleEnabled = false
//            let gradientColors = [UIColor(red:0.75, green:0.92, blue:0.99, alpha:1.00).cgColor,
//                                  UIColor(red:0.57, green:0.90, blue:0.90, alpha:1.00).cgColor]
//            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            set2.fillAlpha = 0.5
//            set2.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            set2.drawFilledEnabled = true
            set2Arr.append(set2)
        }
        set2Arr.insert(set1, at: 0)
        return (set2Arr, Int(totalClimbDistanceV), Int(totalDistanceV), Int(climbDistanceV))
    }
    
    func setAltimeterLineChart2() -> ([LineChartDataSet], Int, Int, Int) {
        var yVals1 = Array<ChartDataEntry>()
        var yVals1Arr = Array<Array<ChartDataEntry>>()
        
        var altimeterValue = 0.0
        var lastAltimeterValue = 0.0
        
        var lastLocation: CLLocation!
        var currentLocation: CLLocation!
        var totalDistanceV: CLLocationDistance = 0.0
        var totalClimbDistanceV: CLLocationDistance = 0.0
        var climbDistanceV: CLLocationDistance = 0.0
        var lastData: ChartDataEntry = ChartDataEntry()
        var currentData: ChartDataEntry = ChartDataEntry()
        var xValue = cyclingData.cyclingLocations[0].timestamp.timeIntervalSince1970
        
        for index in 0..<cyclingData.cyclingGeoLocations.count {
            currentLocation = cyclingData.cyclingGeoLocations[index]
            altimeterValue = cyclingData.altimeters[index] + 10
            currentData = ChartDataEntry(x: xValue, y: altimeterValue)
            xValue += 1
            yVals1.append(currentData) //记录所有点
            
            if index != 0  {
                totalDistanceV += currentLocation.distance(from: lastLocation)
                let delt = altimeterValue - lastAltimeterValue
                if delt > min && delt < max {
                    climbDistanceV += currentLocation.distance(from: lastLocation)//爬坡距离
                    totalClimbDistanceV += delt //累计爬升距离
                    var yVals2 = Array<ChartDataEntry>()
                    yVals2.append(lastData)
                    yVals2.append(currentData) //记录上升点
                    yVals1Arr.append(yVals2)
                }
            }
            lastLocation = currentLocation
            lastData = currentData
            lastAltimeterValue = altimeterValue
        }
        
        let set1: LineChartDataSet
        var set2Arr = [LineChartDataSet]()
        set1 = LineChartDataSet(values: yVals1, label: "所有点")
        set1.axisDependency = .left
        set1.colors = [UIColor(red:0.57, green:0.53, blue:0.98, alpha:1.00)]
        set1.circleColors = [UIColor.red]
        set1.circleRadius = 2.0
        set1.lineWidth = 2.0
        set1.fillAlpha = 65/255.0
        set1.fillColor = UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)
        set1.drawCircleHoleEnabled = false
        
        for index in 0..<yVals1Arr.count {
            let set2 = LineChartDataSet(values: yVals1Arr[index], label: "上升点")
            set2.axisDependency = .left
            set2.colors = [UIColor(red:0.17, green:0.58, blue:0.94, alpha:1.00)]
            set2.drawCirclesEnabled = false
            //            set2.circleColors = [UIColor.white]
            //            set2.circleRadius = 3.0
            set2.lineWidth = 2.0
            set2.fillAlpha = 65/255.0
            set2.fillColor = UIColor.black
            set2.drawCircleHoleEnabled = false
            //            let gradientColors = [UIColor(red:0.75, green:0.92, blue:0.99, alpha:1.00).cgColor,
            //                                  UIColor(red:0.57, green:0.90, blue:0.90, alpha:1.00).cgColor]
            //            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            set2.fillAlpha = 0.5
            //            set2.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            set2.drawFilledEnabled = true
            set2Arr.append(set2)
        }
        set2Arr.insert(set1, at: 0)
        return (set2Arr, Int(totalClimbDistanceV), Int(totalDistanceV), Int(climbDistanceV))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let maxStr = maxValue.text {
            max = (maxStr as NSString).doubleValue
        }
        if let minStr = minValue.text {
            min = (minStr as NSString).doubleValue
        }
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         maxValue.resignFirstResponder()
         minValue.resignFirstResponder()
        return true
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
