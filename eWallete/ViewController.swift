//
//  ViewController.swift
//  eWallete
//
//  Created by HARIKA on 02/07/17.
//  Copyright © 2017 HARIKAharika. All rights reserved.
//

import UIKit
import CoreData

let kFIRSTRUN = "firstRun"
let kDATEFORMAT = "dateFormat"
let kDATEFORMATSTRING = "dateFormatStrig"
let kCURRENCY = "currency"
let kCURRENCYSTRING = "currencyString"



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    @IBOutlet weak var sortSegmentController:UISegmentedControl!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView?
    var expenses: [Expense] = []
    
    @IBOutlet weak var monthNameLabel: UILabel!
    
    
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    var fetchResultController = NSFetchedResultsController()
    
    var calendar:NSCalendar?
 
    
    var currentYear: Int?
    var currentMonth: Int?
    var currentWeek: Int?
    
    var thisYear: Int?
    var firstRun: Bool?
    
    var currency = ""
    var dateFormat = ""
    
    let red = UIColor(red: 204/255, green: 24/255, blue: 48/255, alpha: 1.0)
    let green = UIColor(red: 51/255, green: 161/255, blue: 21/255, alpha: 1.0)
    
    override func viewWillAppear(animated: Bool) {
        firstRunCheck()
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar = NSCalendar.currentCalendar()
        calendar?.firstWeekday = 2 // Monday
        setupCurrentDate()
        
        sortSegmentController.selectedSegmentIndex = 1
        updateFetch()
        updateUI()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : Table view datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchResultController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return fetchResultController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ExpenseTableViewCell
        let expense = fetchResultController.objectAtIndexPath(indexPath) as! Expense
        
        cell.nameLabel.text = expense.name
        cell.amountLabel.text = String(format: "\(currency)%.2f", Double(expense.amount!))
        if expense.isExpense!.boolValue {
            cell.amountLabel.textColor = red
        } else {
            cell.amountLabel.textColor = green
        }
            
        
        return cell
    }
    
    
    // MARK : Tableview delegates
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 28.0))
        headerView.backgroundColor = UIColor.whiteColor()
        let line = UIView(frame: CGRect(x: 0, y: 28, width: tableView.frame.width, height: 1.0))
        line.backgroundColor = green
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width - 1, height: 27.0))
        headerView.addSubview(dateLabel)
        headerView.addSubview(line)
        
        // get expense date
        
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
    
        let expense = fetchResultController.objectAtIndexPath(indexPath) as! Expense
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, \(dateFormat)"
        
        let date = dateFormatter.stringFromDate(expense.date!)
        
        dateLabel.text = date
        return headerView
        
    }
    func tableView(tableView: UITableView, viewForFooterInsection section: Int) ->UIView? {
        let footerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.width,height: tableView.frame.height))
        footerView.backgroundColor = UIColor.clearColor()
        
        return footerView
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexpath: NSIndexPath) {
        let expense = fetchResultController.objectAtIndexPath(indexpath) as! Expense
        appDelegate.managedObjectContext.deleteObject(expense)
        appDelegate.saveContext()
        updateUI()
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    //MARK : ActionButtons
    
    
    @IBAction func sortSegment(sender: UISegmentedControl) {
        
        setupCurrentDate()
        updateFetch()
        updateUI()
    }
    
    @IBAction func nextMonthButtonPressed(sender: UIButton) {
        sortSegmentController.selectedSegmentIndex = 1
        if currentMonth == 12 {
            currentMonth = 1
            currentYear! += 1
        }else {
            currentMonth! += 1
        }
        updateFetch()
        updateUI()
    }
    
    
    
    @IBAction func prevMonthButtonPressed(sender: UIButton) {
        sortSegmentController.selectedSegmentIndex = 1
        if currentMonth == 1 {
            currentMonth = 12
            currentYear! -= 1
        } else {
            currentMonth! -= 1
        }
        updateFetch()
        updateUI()
    }

    
        
    
    @IBAction func addBarButtonItemPressed(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("mainToAddSed", sender: self)
    }
    
    
    @IBAction func settingsBarButtonItemPressed(sender: UIBarButtonItem) {
    }

    
    //MARK : Helper Functions
    
    func updateFetch() {
        fetchResultController = getFetchResultsController()
        fetchResultController.delegate = self
     
        do {
            try fetchResultController.performFetch()
        } catch _ {
            
        }
    }
    
    func expenseFetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Expense")
    
        let sortDescroiptor = NSSortDescriptor(key: "date", ascending: false)
    
        //update segment
        switch  sortSegmentController.selectedSegmentIndex {
        case 0:
            fetchRequest.predicate = NSPredicate(format: "weekOfTheYear = %i", currentWeek!)
        case 1:
            fetchRequest.predicate = NSPredicate(format: "year = %i && monthOfTheYear = %i", currentYear!, currentMonth!)
            
        default:
            fetchRequest.predicate = NSPredicate(format: "year = %i", currentYear!)

        }
        
        
        fetchRequest.sortDescriptors = [sortDescroiptor]
        expenses = (try!
            self.appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)) as!
                [Expense]
        
        return fetchRequest
    }

    func  getFetchResultsController() -> NSFetchedResultsController {
        fetchResultController = NSFetchedResultsController(fetchRequest: expenseFetchRequest(), managedObjectContext: self.appDelegate.managedObjectContext, sectionNameKeyPath: "dateString", cacheName: nil)
        
        return fetchResultController
    }
    
    func updateUI() {
         if currentYear == thisYear {
            //show month only
        monthNameLabel.text = nameOfTheMonthFromMonthNumber(currentMonth!)
        } else{
            //show year too
           monthNameLabel.text = "\(nameOfTheMonthFromMonthNumber(currentMonth!)), \(currentYear!)"

        }
        
        expenseFetchRequest()
        var incomeAmount = 0.0
        var expenseAmount = 0.0
        var totalAmount = 0.0
        
        for expense in expenses {
            if expense.isExpense!.boolValue {
                expenseAmount += Double(expense.amount!)
                
            } else {
                incomeAmount += Double(expense.amount!)
           }
                    }
        
        totalAmount = incomeAmount - expenseAmount
        
        expenseLabel.text = String(format: "\(currency)%.2f", expenseAmount)
        expenseLabel.textColor = red
        expenseLabel.adjustsFontSizeToFitWidth = true
     
        
        
        incomeLabel.text = String(format: "\(currency)%.2f", incomeAmount)
        incomeLabel.textColor = green
        incomeLabel.adjustsFontSizeToFitWidth = true
        
        
        totalLabel.text = String(format: "\(currency)%.2f", totalAmount)
        totalLabel.adjustsFontSizeToFitWidth = true
        
        if totalAmount < -0.01 {
            totalLabel.textColor = red
        } else {
            totalLabel.textColor = green
        }

}
    
    func nameOfTheMonthFromMonthNumber(monthNumber: Int) -> String {
        let monthNames = [" January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return monthNames[monthNumber - 1]
    }
    
    func calendarComponents() -> NSDateComponents {
        let components = calendar!.components([ NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())
        thisYear = components.year
        return components
    }
    func setupCurrentDate()  {
        currentMonth = calendarComponents().month
        currentWeek = calendarComponents().weekOfYear
        currentYear = calendarComponents().year
    
    }
    
    
    func firstRunCheck() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        firstRun = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstRun! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setObject("€", forKey: kCURRENCY)
            userDefaults.setObject("EUR, €", forKey: kCURRENCYSTRING)
            userDefaults.setObject("dd MMMM yyyy", forKey: kDATEFORMAT)
            userDefaults.setObject("Day Month year", forKey: kDATEFORMATSTRING)
            userDefaults.synchronize()
        }
        
        currency = userDefaults.objectForKey(kCURRENCY) as! String
        dateFormat = userDefaults.objectForKey(kDATEFORMAT) as! String
        
    }
  
    
    //MARK: NSFetchedResultsController Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Update UITableview
         
    }
    //mark: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainToEditSeg" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView?.indexPathForCell(cell)
           let expense = fetchResultController.objectAtIndexPath(indexPath!) as! Expense
            let editVC = segue.destinationViewController as! AddExpenseViewController
            editVC.expense = expense
        }
        
    }
    
}

