//
//  AddTransactionViewController.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 10/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import UIKit
import CoreData
import MaterialComponents

class AddExpenseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var amountTextField: MDCTextField!
    @IBOutlet weak var descriptionTextField: MDCTextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var uploadImageView: UIImageView!
    
    var uploadImageSet: Int = 0
    
    var amountController: MDCTextInputControllerOutlined?
    var descriptionController: MDCTextInputControllerOutlined?
    
    var allMonthExpenditures: [NSManagedObject] = []
    var yearExpenditureAmount: Double = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountController = MDCTextInputControllerOutlined(textInput: amountTextField)
        descriptionController = MDCTextInputControllerOutlined(textInput: descriptionTextField)
        
        amountController?.borderFillColor = UIColor.white
        descriptionController?.borderFillColor = UIColor.white
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageSet = 0
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        uploadImageView.image = selectedImage
        uploadImageSet = 1
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageToUpload(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = .camera
        
        let actionsheet = UIAlertController(title: "Photo Source", message: "Choose A Source", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera is Not Available")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var uploadImage: UIImage? = UIImage()
        
        guard let inputAmount:Double = Double(amountTextField.text!) else {
            let alert = UIAlertController(title: "Not a number", message: "Please enter a number for the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        let inputDescription = descriptionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let inputDate = datePicker.date
        if (uploadImageSet == 1) {
            uploadImage = uploadImageView.image!
        } else {
            uploadImage = nil
        }
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
        
        saveExpense(amount: inputAmount, expenseDescription: inputDescription, userId: userId, date: inputDate, month: month, year: year, image: uploadImage)
        updateMonthExpenditure(userId: userId, month: month, year: year, amount: inputAmount)
        updateYearExpenditure(userId: userId, year: year)
        dismiss(animated: true, completion: nil)
        
    }
    
    func saveExpense(amount: Double, expenseDescription: String, userId: String, date: Date, month: Int, year: Int, image: UIImage?) {
        
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
        
        
        if (image != nil) {
            let imageData = image?.pngData()
            expense.setValue(imageData, forKey: "image")
        }
        
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
        let yearPredicate = NSPredicate(format: "year == %@", NSNumber(value: year))
        //fetchRequest.predicate = NSPredicate(format: "level = %ld AND section = %ld", level, section)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userIdPredicate, monthPredicate, yearPredicate])
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
    
    
    
}
