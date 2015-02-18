//
//  MachineTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/20/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MachineTableViewController: UITableViewController {

    @IBOutlet weak var creditsOutlet: UIBarButtonItem!
    
    var machines = [Machine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Machines"

        if !AuthenticationManager.keyIsValid() {
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        
        CurrentUser.sharedInstance.credits.bindAndFire {
            [unowned self] in
            self.creditsOutlet.title = "\($0) Credits"
        }
        
        updateMachines()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CurrentUser.updateUser()
    }
    
    func refresh(sender: AnyObject) {
        updateMachines()
    }
    
    func updateMachines() {
        var machines = [Machine]()
        Alamofire.request(.GET, "https://webdrink.csh.rit.edu/api/index.php?request=machines/stock", parameters: ["api_key": AuthenticationManager.apiKey]).responseJSON { (_, _, data, _) in
            let json = JSON(data!)
            for (machineId: String, machine: JSON) in json["data"] {
                var items = [Item]()
                for (itemIndex: String, item: JSON) in machine {
                    items.append(Item(
                        name: item["item_name"].stringValue,
                        price: item["item_price"].intValue,
                        machine_id: item["machine_id"].intValue,
                        slot_num: item["slot_num"].intValue,
                        available: item["available"].intValue,
                        item_id: item["item_id"].intValue
                    ))
                }
                if items.count > 0 {
                    machines.append(Machine(name: machine[0]["display_name"].stringValue, items: items))
                }
            }
            self.machines = machines
            self.refreshControl?.endRefreshing()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MachineTableViewCell
        
        let machine = self.machines[indexPath.row]
        
        cell.titleLabel.text = machine.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("machineDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "machineDetail" {
            let machineDetailViewController = segue.destinationViewController as ItemTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let destinationTitle = self.machines[indexPath.row].name
            machineDetailViewController.title = destinationTitle
            machineDetailViewController.items = self.machines[indexPath.row].items
        }
    }

}
