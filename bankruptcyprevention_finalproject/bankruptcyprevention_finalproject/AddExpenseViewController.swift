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
        
        let inputAmount = Double(amountTextField.text!)!
        let inputDescription = descriptionTextField.text!
        let inputDate = datePicker.date
        
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
        }
        
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        save(amount: inputAmount, expenseDescription: inputDescription, userId: userId, date: inputDate)
        dismiss(animated: true, completion: nil)
        
    }
    
    func save(amount: Double, expenseDescription: String, userId: String, date: Date) {
        
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
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
