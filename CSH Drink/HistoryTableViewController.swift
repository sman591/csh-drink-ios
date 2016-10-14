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
import Punctual

class HistoryTableViewController: UITableViewController {

    var drops = [Drop]()
    var updatedAt = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateHistory()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(HistoryTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let comparison = CurrentUser.sharedInstance.updatedAt.compare(updatedAt)
        if comparison == ComparisonResult.orderedDescending
            || comparison == ComparisonResult.orderedSame
            || updatedAt.compare(1.minute.ago!) == ComparisonResult.OrderedAscending {
            updateHistory()
        }
    }

    func refresh(_ sender: AnyObject) {
        updateHistory()
    }
    
    func updateHistory() {
        var drops = [Drop]()
        DrinkAPI.getDrops(completion: { data in
            for (_, drop): (String, JSON) in data {
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
            self.updatedAt = NSDate()
        }, failure: { (error, message) in
            self.refreshControl?.endRefreshing()
            DrinkAPI.genericApiError(self.view.window!.rootViewController!, message: message)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.drops.count
    }
    
    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DropTableViewCell
        
        let drop = self.drops[(indexPath as NSIndexPath).row]
        
        cell.itemNameLabel.text = drop.item_name
        cell.machineNameLabel.text = drop.machine_name
        cell.timeLabel.text = drop.time
        cell.creditsLabel.text = drop.humanPrice()
        
        return cell
    }

}

