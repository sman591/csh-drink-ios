//
//  ItemTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import HanekeSwift

class ItemTableViewController: UITableViewController {
    
    var items: [Item]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return self.items.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as ItemTableViewCell
        
        let item = self.items[indexPath.row]
        
        cell.titleLabel.text = item.name
        cell.creditsLabel.text = "\(item.price) Credit"
        if item.price != 1 {
            cell.creditsLabel.text = cell.creditsLabel.text! + "s"
        }
        
        cell.userInteractionEnabled = item.enabled()
        
        var textColor: UIColor
        
        if item.enabled() {
            textColor = UIColor(white: 0.29, alpha: 1)
        } else {
            textColor = UIColor(white: 0.29, alpha: 0.25)
        }
        
        cell.titleLabel.textColor = textColor
        cell.creditsLabel.textColor = textColor
        cell.itemImage.hnk_setImageFromURL(NSURL(string: "https://csh.rit.edu/~mbillow/drink_icons/hdpi/\(item.item_id).png")!)

        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("itemDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "itemDetail" {
            let itemDetailViewController = segue.destinationViewController as ItemViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let item = self.items[indexPath.row]
            let destinationTitle = item.name
            itemDetailViewController.title = destinationTitle
            itemDetailViewController.item = item
        }
    }
    
}