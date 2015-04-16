//
//  HistoryTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/20/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HistoryTableViewController: UITableViewController {

    var drops = [Drop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateHistory()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    func refresh(sender: AnyObject) {
        updateHistory()
    }
    
    func updateHistory() {
        var drops = [Drop]()
        DrinkAPI.getDrops(completion: { data in
            for (dropIndex: String, drop: JSON) in data {
                var items = [Item]()
                drops.append(Drop(
                    item_name: drop["item_name"].stringValue,
                    item_price: drop["current_item_price"].intValue,
                    machine_name: drop["display_name"].stringValue,
                    time: drop["time"].stringValue))
            }
            self.refreshControl?.endRefreshing()
            if drops.count > self.drops.count {
                self.drops = drops
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.drops.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DropTableViewCell
        
        var drop = self.drops[indexPath.row]
        
        cell.itemNameLabel.text = drop.item_name
        cell.machineNameLabel.text = drop.machine_name
        cell.timeLabel.text = drop.time
        cell.creditsLabel.text = drop.humanPrice()
        
        return cell
    }

}

