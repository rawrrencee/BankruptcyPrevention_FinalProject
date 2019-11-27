//
//  EditExpenseViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 20/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import CoreData
import MaterialComponents

class EditExpenseViewController: UIViewController {
    
    var expenses: [NSManagedObject] = []
    var selectedIndex:Int = Int()
    
    var allMonthExpenditures: [NSManagedObject] = []
    var yearExpenditureAmount: Double = 0.00
    
    @IBOutlet weak var editAmountTextField: MDCTextField!
    @IBOutlet weak var editDescriptionTextField: MDCTextField!
    @IBOutlet weak var editDatePicker: UIDatePicker!
    
    var editAmountController: MDCTextInputControllerOutlined?
    var editDescriptionController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amount:Double = expenses[selectedIndex].value(forKey: "amount") as! Double
        editAmountTextField.text = "\(amount.truncate(places: 2))"
        editDescriptionTextField.text = expenses[selectedIndex].value(forKey: "expenseDescription") as? String
        editDatePicker.date = expenses[selectedIndex].value(forKey: "date") as! Date
        
        editAmountController = MDCTextInputControllerOutlined(textInput: editAmountTextField)
        editDescriptionController = MDCTextInputControllerOutlined(textInput: editDescriptionTextField)
        
        editAmountController?.borderFillColor = UIColor.white
        editDescriptionController?.borderFillColor = UIColor.white
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editExpenseSaveButtonPressed(_ sender: Any) {
        guard let inputAmount:Double = Double(editAmountTextField.text!) else {
            let alert = UIAlertController(title: "Not a number", message: "Please enter a number for the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        let inputDescription = editDescriptionTextField.text!
        let originalDate = expenses[selectedIndex].value(forKey: "date") as! Date
        let originalYear = Calendar.current.component(.year, from: originalDate)
        let originalMonth = Calendar.current.component(.month, from: originalDate)
        
        let inputDate = editDatePicker.date
        let year = Calendar.current.component(.year, from: inputDate)
        let month = Calendar.current.component(.month, from: inputDate)
        print(month)
        
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
        
        let originalAmount = expenses[selectedIndex].value(forKey: "amount") as! Double
        
        updateExpense(amount: inputAmount, expenseDescription: inputDescription, userId: userId, originalDate: originalDate, modifiedDate: inputDate, month: month, year: year)
        updateMonthExpenditure(originalMonth: originalMonth, modifiedMonth: month, originalYear: originalYear, modifiedYear: year, amountToDeduct: originalAmount, amountToAdd: inputAmount)
        updateYearExpenditure(userId: userId, year: originalYear)
        updateYearExpenditure(userId: userId, year: year)
        dismiss(animated: true, completion: nil)
    }
    
    func updateExpense(amount: Double, expenseDescription: String, userId: String, originalDate: Date, modifiedDate: Date, month: Int, year: Int) {
        
        var expense: [NSManagedObject] = []
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Expense")
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        
        let userIdPredicate = NSPredicate(format: "userId == %@", userId)
        let datePredicate = NSPredicate(format: "date = %@", originalDate as NSDate)
        //fetchRequest.predicate = NSPredicate(format: "level = %ld AND section = %ld", level, section)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, datePredicate])
        fetchRequest.predicate = andPredicate
        
        do {
            try expense = managedContext.fetch(fetchRequest)
            
            print (expense[0])
            
            expense[0].setValue(amount, forKeyPath: "amount")
            expense[0].setValue(expenseDescription, forKeyPath: "expenseDescription")
            expense[0].setValue(modifiedDate, forKeyPath: "date")
            expense[0].setValue(month, forKeyPath: "month")
            expense[0].setValue(year, forKeyPath: "year")
            
            do {
                try managedContext.save()
                print("Expense amount updated.")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateMonthExpenditure(originalMonth: Int, modifiedMonth: Int, originalYear: Int, modifiedYear: Int, amountToDeduct: Double, amountToAdd: Double) {
        
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
        var monthPredicate = NSPredicate(format: "month == %@", NSNumber(value: originalMonth))
        var yearPredicate = NSPredicate(format: "year == %@", NSNumber(value: originalYear))
        //fetchRequest.predicate = NSPredicate(format: "level = %ld AND section = %ld", level, section)
        var andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, monthPredicate, yearPredicate])
        fetchRequest.predicate = andPredicate
        
        //3
        do {
            monthExpenditure = try managedContext.fetch(fetchRequest)
            
            var monthAmount = monthExpenditure[0].value(forKeyPath: "amount") as! Double
            monthAmount = monthAmount - amountToDeduct
            monthExpenditure[0].setValue(monthAmount, forKey: "amount")
            monthExpenditure[0].setValue(originalMonth, forKeyPath: "month")
            monthExpenditure[0].setValue(originalYear, forKeyPath: "year")
            
            do {
                try managedContext.save()
                print("Month amount for \(originalMonth)/\(originalYear) updated to $\(monthAmount).")
                
                monthPredicate = NSPredicate(format: "month == %@", NSNumber(value: modifiedMonth))
                yearPredicate = NSPredicate(format: "year == %@", NSNumber(value: modifiedYear))
                andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, monthPredicate, yearPredicate])
                fetchRequest.predicate = andPredicate
                
                try monthExpenditure = managedContext.fetch(fetchRequest)
                
                if (monthExpenditure.isEmpty) {
                    // 2
                    let entity =
                        NSEntityDescription.entity(forEntityName: "MonthExpenditure",
                                                   in: managedContext)!
                    
                    let monthExpenditure = NSManagedObject(entity: entity,
                                                           insertInto: managedContext)
                    
                    // 3
                    monthExpenditure.setValue(amountToAdd, forKeyPath: "amount")
                    monthExpenditure.setValue(userId, forKeyPath: "userId")
                    monthExpenditure.setValue(modifiedMonth, forKeyPath: "month")
                    monthExpenditure.setValue(modifiedYear, forKeyPath: "year")
                    
                    // 4
                    do {
                        try managedContext.save()
                        print("New month for \(modifiedMonth)/\(modifiedYear) saved with $\(amountToAdd).")
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                } else {
                    var monthAmount = monthExpenditure[0].value(forKeyPath: "amount") as! Double
                    monthAmount = monthAmount + amountToAdd
                    monthExpenditure[0].setValue(monthAmount, forKey: "amount")
                    do {
                        try managedContext.save()
                        print("Month amount updated to $\(monthAmount).")
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    
    
    
    func updateYearExpenditure(userId: String, year: Int) {
        
        fetchAllMonthExpenditures(year: year)
        calculateTotalYearExpenditure()
        
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
            NSFetchRequest<NSManagedObject>(entityName: "YearExpenditure")
        
        fetchRequest.predicate = NSPredicate(format: "userId = %@ AND year = %@", userId, NSNumber(value: year))
        
        //3
        do {
            
            let yearExpenditure = try managedContext.fetch(fetchRequest)
            
            if (yearExpenditure.isEmpty) {
                let entity =
                    NSEntityDescription.entity(forEntityName: "YearExpenditure",
                                               in: managedContext)!
                
                let yearExpenditure = NSManagedObject(entity: entity,
                                                      insertInto: managedContext)
                
                // 3
                yearExpenditure.setValue(yearExpenditureAmount, forKeyPath: "amount")
                yearExpenditure.setValue(userId, forKeyPath: "userId")
                yearExpenditure.setValue(year, forKeyPath: "year")
                
                // 4
                do {
                    try managedContext.save()
                    print("New year saved.")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                yearExpenditure[0].setValue(yearExpenditureAmount, forKey: "amount")
                
                do {
                    try managedContext.save()
                    print("Year amount updated.")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchAllMonthExpenditures(year: Int) {
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
        
        fetchRequest.predicate = NSPredicate(format: "userId = %@ AND year = %@", userId, NSNumber(value: year))
        
        
        let sort = NSSortDescriptor(key: #keyPath(MonthExpenditure.month), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        //3
        do {
            allMonthExpenditures = try managedContext.fetch(fetchRequest)
            calculateTotalYearExpenditure()
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

