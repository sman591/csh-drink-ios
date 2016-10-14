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
import Mixpanel

class MachineTableViewController: UITableViewController {

    @IBOutlet weak var creditsOutlet: UIBarButtonItem!
    
    var machines = [Machine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Machines"

        if !CurrentUser.isLoggedIn() {
            self.performSegue(withIdentifier: "goto_login", sender: self)
        }
        
        CurrentUser.sharedInstance.credits.bindAndFire {
            [unowned self] in
            self.creditsOutlet.title = "\($0) " + ("credit".pluralize($0))
        }
        
        updateMachines()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MachineTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarItem.image = UIImage(named: "drink-outline")
        self.tabBarItem.selectedImage = UIImage(named: "drink")
        super.viewDidAppear(animated)
    }
    
    func refresh(_ sender: AnyObject) {
        updateMachines()
        CurrentUser.updateUser()
    }
    
    func updateMachines() {
        var machines = [Machine]()
        DrinkAPI.getMachinesStock({ data in
            for (_, machine): (String, JSON) in data {
                var items = [Item]()
                for (_, item): (String, JSON) in machine {
                    items.append(Item(
                        name: item["item_name"].stringValue,
                        price: item["item_price"].intValue,
                        machine_id: item["machine_id"].intValue,
                        slot_num: item["slot_num"].intValue,
                        available: item["available"].intValue,
                        item_id: item["item_id"].intValue,
                        status: item["status"].stringValue
                    ))
                }
                if items.count > 0 {
                    machines.append(Machine(name: machine[0]["display_name"].stringValue, items: items))
                }
            }
            self.machines = machines
            self.refreshControl?.endRefreshing()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }, failure: { error, message in
            self.refreshControl?.endRefreshing()
            DrinkAPI.genericApiError(self.view.window!.rootViewController!, message: message)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.machines.count
    }

    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MachineTableViewCell
        
        let machine = self.machines[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = machine.name
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "machineDetail", sender: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "machineDetail" {
            let machineDetailViewController = segue.destination as! ItemTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let destinationTitle = self.machines[(indexPath as NSIndexPath).row].name
            machineDetailViewController.title = destinationTitle
            machineDetailViewController.items = self.machines[(indexPath as NSIndexPath).row].items
            Mixpanel.sharedInstance().track("Opened machine item list")
        }
    }

}
