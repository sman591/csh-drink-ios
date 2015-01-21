//
//  DropTableViewTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/20/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class DropTableViewTableViewController: UITableViewController {

    var machines = [Machine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.machines = [Machine(name: "Little Drink", drinks: [Drink(name: "Dr. Pepper", price: 1), Drink(name: "Cherry Coke", price: 1)]),
            Machine(name: "Big Drink", drinks: [Drink(name: "JOLT Grape", price: 150), Drink(name: "Saranac Root Beer", price: 100)]),
            Machine(name: "Snack", drinks: [Drink(name: "Kelloggs Nutri Grain", price: 1), Drink(name: "Twizzlers", price: 54)])]
        self.tableView.reloadData()
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
        return self.machines.count
    }

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let machine = self.machines[indexPath.row]
        
        cell.textLabel!.text = machine.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("machineDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "machineDetail" {
            let machineDetailViewController = segue.destinationViewController as DrinkTableViewTableController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let destinationTitle = self.machines[indexPath.row].name
            machineDetailViewController.title = destinationTitle
            machineDetailViewController.drinks = self.machines[indexPath.row].drinks
        }
    }

}
