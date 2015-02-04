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
        Alamofire.request(.GET, "https://webdrink.csh.rit.edu/api/index.php?request=users/info", parameters: ["api_key": AuthenticationManager.apiKey]).responseJSON { (_, _, userData, _) in
            let userData = JSON(userData!)
            Alamofire.request(.GET, "https://webdrink.csh.rit.edu/api/index.php?request=users/drops&limit=25&offset=0", parameters: ["api_key": AuthenticationManager.apiKey, "uid": userData["data"]["uid"].stringValue]).responseJSON { (_, _, data, _) in
                let json = JSON(data!)
                for (dropIndex: String, drop: JSON) in json["data"] {
                    var items = [Item]()
                    self.drops.append(Drop(
                        item_name: drop["item_name"].stringValue,
                        item_price: drop["current_item_price"].intValue,
                        machine_name: drop["display_name"].stringValue,
                        time: drop["time"].stringValue))
                }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55.0
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
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as DropTableViewCell
        
        var drop = self.drops[indexPath.row]
        
        cell.itemNameLabel.text = drop.item_name
        cell.machineNameLabel.text = drop.machine_name
        cell.timeLabel.text = drop.time
        cell.creditsLabel.text = "\(drop.item_price) Credit"
        if drop.item_price != 1 {
            cell.creditsLabel.text = cell.creditsLabel.text! + "s"
        }
        
        return cell
    }

}

