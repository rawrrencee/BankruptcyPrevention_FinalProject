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

class EditExpenseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var expenses: [NSManagedObject] = []
    var selectedIndex:Int = Int()
    
    var allMonthExpenditures: [NSManagedObject] = []
    var yearExpenditureAmount: Double = 0.00
    
    var uploadImageSet: Int = 0
    
    @IBOutlet weak var editAmountTextField: MDCTextField!
    @IBOutlet weak var editDescriptionTextField: MDCTextField!
    @IBOutlet weak var editDatePicker: UIDatePicker!
    @IBOutlet weak var uploadImageView: UIImageView!
    
    var editAmountController: MDCTextInputControllerOutlined?
    var editDescriptionController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (expenses[selectedIndex].value(forKey: "image") as? Data != nil) {
            uploadImageView.image = UIImage(data: expenses[selectedIndex].value(forKey: "image") as! Data)
        }
        
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
    
    @IBAction func viewButtonPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let viewUploadedImageViewController = storyBoard.instantiateViewController(withIdentifier: "viewUploadedImageViewController") as! ViewUploadedImageViewController
        
        viewUploadedImageViewController.uploadedImage = uploadImageView.image
        
        self.present(viewUploadedImageViewController, animated:true, completion:nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewUploadedImageViewController = segue.destination as? ViewUploadedImageViewController
            else {
                return
        }
        viewUploadedImageViewController.uploadedImage = uploadImageView.image
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
    
    @IBAction func editExpenseSaveButtonPressed(_ sender: Any) {
        
        var uploadImage: UIImage? = UIImage()
        
        guard let inputAmount:Double = Double(editAmountTextField.text!) else {
            let alert = UIAlertController(title: "Not a number", message: "Please enter a number for the amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        if (uploadImageSet == 1) {
            uploadImage = uploadImageView.image!
        } else {
            uploadImage = nil
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
        
        updateExpense(amount: inputAmount, expenseDescription: inputDescription, userId: userId, originalDate: originalDate, modifiedDate: inputDate, month: month, year: year, image: uploadImage)
        updateMonthExpenditure(originalMonth: originalMonth, modifiedMonth: month, originalYear: originalYear, modifiedYear: year, amountToDeduct: originalAmount, amountToAdd: inputAmount)
        updateYearExpenditure(userId: userId, year: originalYear)
        updateYearExpenditure(userId: userId, year: year)
        dismiss(animated: true, completion: nil)
    }
    
    func updateExpense(amount: Double, expenseDescription: String, userId: String, originalDate: Date, modifiedDate: Date, month: Int, year: Int, image: UIImage?) {
        
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
            
            if (image != nil) {
                let imageData = image?.pngData()
                expense[0].setValue(imageData, forKey: "image")
            }
            
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

