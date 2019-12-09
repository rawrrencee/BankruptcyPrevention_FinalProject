//
//  ReportViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 10/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ReportViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var yearExpenditureAmountLabel: UILabel!
    
    var allMonthExpenditures: [NSManagedObject] = []
    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var monthlyExpenditureAmounts: [Double] = []
    var yearExpenditureAmount: Double = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllMonthExpenditures(year: Calendar.current.component(.year, from: Date()))
        calculateTotalYearExpenditure()
        
        if (yearExpenditureAmount < 0) {
            let absolute = yearExpenditureAmount * -1
            yearExpenditureAmountLabel.text = "-$\(absolute.truncate(places: 2))"
        } else {
            yearExpenditureAmountLabel.text = "$\(yearExpenditureAmount.truncate(places: 2))"
        }
        
        customizeChart(dataPoints: months, values: monthlyExpenditureAmounts)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllMonthExpenditures(year: Calendar.current.component(.year, from: Date()))
        calculateTotalYearExpenditure()
        yearExpenditureAmountLabel.text = "$\(yearExpenditureAmount.truncate(places: 2))"
        barChartView.notifyDataSetChanged()
        customizeChart(dataPoints: months, values: monthlyExpenditureAmounts)
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Amount")
        chartDataSet.colors = ChartColorTemplates.material()
        let chartData = BarChartData(dataSet: chartDataSet)
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.labelCount = 12
        
        barChartView.data = chartData
        
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBounce)
        barChartView.chartDescription?.enabled = false
        barChartView.legend.enabled = false
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.rightAxis.enabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        
        barChartView.leftAxis.drawGridLinesEnabled = false
        
        barChartView.dragEnabled = true
        barChartView.setScaleEnabled(true)
        barChartView.pinchZoomEnabled = true
        barChartView.scaleYEnabled = false
        
    }
    
    func fetchAllMonthExpenditures(year: Int) {
        
        monthlyExpenditureAmounts.removeAll()
        
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MonthExpenditure")
        
        let userIdPredicate = NSPredicate(format: "userId == %@", userId)
        let yearPredicate = NSPredicate(format: "year == %@", NSNumber(value: year))
        //fetchRequest.predicate = NSPredicate(format: "level = %ld AND section = %ld", level, section)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, yearPredicate])
        fetchRequest.predicate = andPredicate
        
        let sort = NSSortDescriptor(key: #keyPath(MonthExpenditure.month), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do {
            allMonthExpenditures = try managedContext.fetch(fetchRequest)
            
            for mth in 1...12 {
                for month in allMonthExpenditures {
                    if (month.value(forKey: "month") as! Int == mth) {
                        monthlyExpenditureAmounts.append(month.value(forKey: "amount") as! Double)
                    }
                }
                
                if (monthlyExpenditureAmounts.count != mth) {
                    monthlyExpenditureAmounts.append(Double(0.00))
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func calculateTotalYearExpenditure() {
        
        yearExpenditureAmount = 0.00
        
        if (!allMonthExpenditures.isEmpty) {
            for month in allMonthExpenditures {
                yearExpenditureAmount += month.value(forKey: "amount") as! Double
            }
        }
    }
    
}
