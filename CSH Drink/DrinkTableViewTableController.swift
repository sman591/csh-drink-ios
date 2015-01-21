//
//  DrinkTableViewTableController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class DrinkTableViewTableController: UITableViewController {
    
    var drinks: [Drink]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.drinks.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let machine = self.drinks[indexPath.row]
        
        cell.textLabel!.text = machine.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("drinkDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "drinkDetail" {
            let drinkDetailViewController = segue.destinationViewController as DrinkViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let drink = self.drinks[indexPath.row]
            let destinationTitle = drink.name
            drinkDetailViewController.title = destinationTitle
            drinkDetailViewController.drink = drink
        }
    }
    
}