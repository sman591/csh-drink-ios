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

    let delayOptions = [10, 20, 30, 45, 60]
    
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
        cell.creditsLabel.text = item.humanPrice()
        
        cell.userInteractionEnabled = item.enabled() && CurrentUser.canAffordItem(item)
        
        var textColor: UIColor
        var alpha: CGFloat
        
        if item.enabled() && CurrentUser.canAffordItem(item) {
            alpha = 1
            textColor = UIColor(white: 0.29, alpha: alpha)
        } else {
            alpha = 0.25
            textColor = UIColor(white: 0.29, alpha: alpha)
        }
        
        cell.titleLabel.textColor = textColor
        cell.creditsLabel.textColor = textColor
        cell.itemImage.hnk_setImageFromURL(NSURL(string: "https://csh.rit.edu/~mbillow/drink_icons/hdpi/\(item.item_id).png")!)
        cell.itemImage.alpha = alpha

        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Do nothing, required for table cell edit actions
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var actions = NSMutableArray() // TODO: better swift syntax for this?
        var saturation : CGFloat = 0.73
        for delay in reverse(delayOptions) {
            var action = UITableViewRowAction(style: .Default, title: "\(delay)s") { (rowAction, indexPath) -> Void in
                self.tableView.setEditing(false, animated: true)
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                self.confirmDrop(
                    self.items[indexPath.row],
                    delay: delay,
                    dismiss: {
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    }
                )
            }
            action.backgroundColor = UIColor(hue: 339.0/359.0, saturation: saturation, brightness: 0.91, alpha: 1.0)
            actions.addObject(action)
            saturation -= 0.069
        }
        return actions
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as ItemTableViewCell
        confirmDrop(
            self.items[indexPath.row],
            delay: 0,
            dismiss: {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        )
    }

    func confirmDrop(item: Item, delay: Int, dismiss: (() -> (Void))?) {
        var text = "\(item.name) for \(item.humanPrice().lowercaseString)"
        if delay > 0 {
            text += " in \(delay) seconds"
        }

        var alertview = JSSAlertView().show(self, title: "Drop Confirmation", text: text, buttonText: "Drop", cancelButtonText: "Cancel", color: UIColor(red: 0.906, green: 0.243, blue: 0.478, alpha: 1.0))
        alertview.setTitleFont("CriqueGrotesk")
        alertview.setTextFont("CriqueGrotesk")
        alertview.setButtonFont("CriqueGrotesk")
        alertview.setTextTheme(.Light)
        alertview.addAction() {
            self.drop(item, delay: delay, completion: dismiss?, failure: dismiss?)
        }
        alertview.addCancelAction() {
            if let callback = dismiss? {
                callback()
            }
        }
    }
    
    func drop(item: Item, delay: Int,  completion: (() -> (Void))? = nil, failure: (() -> (Void))? = nil) {
        var droppingView = JSSAlertView().show(self, title: "Dropping...", text: "In \(delay) seconds...", buttonText: "Ignore", color: UIColor(red: 0.906, green: 0.243, blue: 0.478, alpha: 1.0))
        droppingView.setTitleFont("CriqueGrotesk")
        droppingView.setTextFont("CriqueGrotesk")
        droppingView.setButtonFont("CriqueGrotesk")
        droppingView.setTextTheme(.Light)

        if delay > 0 {
            updateCountdown(droppingView.alertview, time: delay - 1) // TODO: this seems broken, could be refactored
        }

        DrinkAPI.dropItem(item, delay: delay,
            completion: { data in
                droppingView.alertview.titleLabel.text = "Dropped!"
                droppingView.alertview.textView.text = "Item successfully dropped"
                droppingView.alertview.buttonLabel.text = "OK"
            }, failure: { error, message in
                droppingView.alertview.titleLabel.text = "Drop Failed"
                droppingView.alertview.textView.text = message ?? "Your item failed to drop"
                droppingView.alertview.buttonLabel.text = "OK"
            }
        )
    }

    func updateCountdown(alertView: JSSAlertView, time: Int) {
        delay(1) {
            if !alertView.isAlertOpen {
                return
            } else if time > 0 && alertView.textView.text.rangeOfString("seconds") != nil {
                alertView.textView.text = "In \(time) seconds..."
                self.updateCountdown(alertView, time: time - 1)
            } else {
                alertView.textView.text = "Dropping..."
            }
        }
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}