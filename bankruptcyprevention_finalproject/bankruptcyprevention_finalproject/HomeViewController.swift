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
    
    @IBOutlet weak var expenseTableView: UITableView!
    
    var expenses: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        // Do any additional setup after loading the view.
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
        
        //3
        do {
            expenses = try managedContext.fetch(fetchRequest)
            print(expenses.count)
            expenseTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func reloadData() {
        expenseTableView.reloadData()
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
        cell.amountLabel.text = "\(amount.truncate(places: 1))"
        
        let description = expense.value(forKeyPath: "expenseDescription") as! String
        cell.descriptionLabel.text = description
        
        let date = expense.value(forKeyPath: "date") as! Date
        cell.dateLabel.text = date.description
        
        return cell
    }

}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
