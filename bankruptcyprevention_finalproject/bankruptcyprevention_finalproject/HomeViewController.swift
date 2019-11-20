//
//  HomeViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 10/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthExpenditureLabel: UILabel!
    @IBOutlet weak var expenseTableView: UITableView!
    
    var expenses: [NSManagedObject] = []
    var currentMonthExpenditureAmount: Double = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        
        fetchMonthExpenditure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Expense")
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        let sort = NSSortDescriptor(key: #keyPath(Expense.date), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do {
            expenses = try managedContext.fetch(fetchRequest)
            reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func reloadData() {
        expenseTableView.reloadData()
        fetchMonthExpenditure()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let expense = expenses[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTableViewCell", for: indexPath) as? ExpenseTableViewCell else {
            fatalError("The dequeued cell is not an instance of ExpenseTableViewCell")
        }
        
        let amount = expense.value(forKeyPath: "amount") as! Double
        if (amount < 0) {
            let absolute = amount * -1
            cell.amountLabel.text = "-$\(absolute.truncate(places: 2))"
        } else {
            cell.amountLabel.text = "$\(amount.truncate(places: 2))"
        }
        
        let description = expense.value(forKeyPath: "expenseDescription") as! String
        cell.descriptionLabel.text = description
        
        let date = expense.value(forKeyPath: "date") as! Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d yyyy"
        let simpleDate = dateFormatter.string(from: date)
        cell.dateLabel.text = simpleDate
        
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            let inverse: Double = expenses[indexPath.row].value(forKey: "amount") as! Double * -1.0
            print (inverse)
            let month = expenses[indexPath.row].value(forKey: "month") as! Int
            let year = expenses[indexPath.row].value(forKey: "year") as! Int
            managedContext.delete(expenses[indexPath.row])
            
            expenses.remove(at: indexPath.row)
            do {
                try managedContext.save()
                updateMonthExpenditure(month: month, year: year, amount: inverse)
                fetchMonthExpenditure()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func fetchMonthExpenditure() {
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let currentMonth = Calendar.current.component(.month, from: Date())
        
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
        
        fetchRequest.predicate = NSPredicate(format: "userId = %@ AND month = %@", userId, NSNumber(value: currentMonth))
        
        //3
        do {
            var currentMonthExpenditure = try managedContext.fetch(fetchRequest)
            if (!currentMonthExpenditure.isEmpty) {
                currentMonthExpenditureAmount = currentMonthExpenditure[0].value(forKey: "amount")  as! Double
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        self.monthExpenditureLabel.text = "$\(currentMonthExpenditureAmount.truncate(places: 2))"
    }
    
    func updateMonthExpenditure(month: Int, year: Int, amount: Double) {
        
        var monthExpenditure: [NSManagedObject] = []
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MonthExpenditure")
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        
        let userIdPredicate = NSPredicate(format: "userId == %@", userId)
        let monthPredicate = NSPredicate(format: "month == %@", NSNumber(value: month))
        //fetchRequest.predicate = NSPredicate(format: "level = %ld AND section = %ld", level, section)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, monthPredicate])
        fetchRequest.predicate = andPredicate
        
        //3
        do {
            monthExpenditure = try managedContext.fetch(fetchRequest)
            
            if (monthExpenditure.isEmpty) {
                // 2
                let entity =
                    NSEntityDescription.entity(forEntityName: "MonthExpenditure",
                                               in: managedContext)!
                
                let monthExpenditure = NSManagedObject(entity: entity,
                                                       insertInto: managedContext)
                
                // 3
                monthExpenditure.setValue(amount, forKeyPath: "amount")
                monthExpenditure.setValue(userId, forKeyPath: "userId")
                monthExpenditure.setValue(month, forKeyPath: "month")
                monthExpenditure.setValue(year, forKeyPath: "year")
                
                // 4
                do {
                    try managedContext.save()
                    print("New month saved.")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                
                var monthAmount = monthExpenditure[0].value(forKeyPath: "amount") as! Double
                monthAmount += amount
                monthExpenditure[0].setValue(monthAmount, forKey: "amount")
                
                do {
                    try managedContext.save()
                    print("Month amount updated.")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editExpenseViewController = segue.destination as? EditExpenseViewController,
            let index = expenseTableView.indexPathForSelectedRow?.row
            else {
                return
        }
        editExpenseViewController.expenses = expenses
        editExpenseViewController.selectedIndex = index
    }
    
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
