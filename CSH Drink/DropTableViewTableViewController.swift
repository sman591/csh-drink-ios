//
//  DropTableViewTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/20/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DropTableViewTableViewController: UITableViewController {

    var machines = [Machine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(.GET, "https://webdrink.csh.rit.edu/api/index.php?request=machines/stock", parameters: ["api_key": ""]).responseJSON { (_, _, data, _) in
            println(data)
            let json = JSON(data!)
            for (machineId: String, machine: JSON) in json["data"] {
                println(machineId)
                var drinks = [Drink]()
                for (drinkIndex: String, drink: JSON) in machine {
                    drinks.append(Drink(name: drink["item_name"].stringValue, price: drink["item_price"].intValue))
                }
                if drinks.count > 0 {
                    self.machines.append(Machine(name: machine[0]["display_name"].stringValue, drinks: drinks))
                }
            }
            self.tableView.reloadData()
            println(json["message"].stringValue)
        }
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
