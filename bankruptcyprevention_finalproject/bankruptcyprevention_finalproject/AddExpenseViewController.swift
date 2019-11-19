//
//  AddTransactionViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 10/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import CoreData

class AddExpenseViewController: UIViewController {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addButtonPressed(_ sender: Any) {
        
        guard let inputAmount:Double = Double(amountTextField.text!) else {
            let alert = UIAlertController(title: "Not a number", message: "Please enter a number for the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        let inputDescription = descriptionTextField.text!
        let inputDate = datePicker.date
        let year = Calendar.current.component(.year, from: inputDate)
        let month = Calendar.current.component(.month, from: inputDate)
        
        if (inputAmount.isNaN) {
            let alert = UIAlertController(title: "Not a number", message: "Please enter a number for the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        if (inputDescription.isEmpty) {
            let alert = UIAlertController(title: "Description is empty", message: "Please enter a description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        saveExpense(amount: inputAmount, expenseDescription: inputDescription, userId: userId, date: inputDate, month: month, year: year)
        updateMonthExpenditure(userId: userId, month: month, year: year, amount: inputAmount)
        dismiss(animated: true, completion: nil)
        
    }
    
    func saveExpense(amount: Double, expenseDescription: String, userId: String, date: Date, month: Int, year: Int) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Expense",
                                       in: managedContext)!
        
        let expense = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        
        // 3
        expense.setValue(amount, forKeyPath: "amount")
        expense.setValue(expenseDescription, forKeyPath: "expenseDescription")
        expense.setValue(userId, forKeyPath: "userId")
        expense.setValue(date, forKeyPath: "date")
        expense.setValue(month, forKeyPath: "month")
        expense.setValue(year, forKeyPath: "year")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateMonthExpenditure(userId: String, month: Int, year: Int, amount: Double) {
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
