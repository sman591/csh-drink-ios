//
//  ItemTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Haneke
import Mixpanel

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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        let item = self.items[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = item.name
        cell.creditsLabel.text = item.humanPrice()
        
        var textColor: UIColor
        var alpha: CGFloat
        
        if item.enabled() && CurrentUser.canAffordItem(item) {
            alpha = 1
            textColor = UIColor(white: 0.29, alpha: alpha)
            cell.isUserInteractionEnabled = true
        } else {
            alpha = 0.25
            textColor = UIColor(white: 0.29, alpha: alpha)
            cell.isUserInteractionEnabled = false
        }
        
        cell.titleLabel.textColor = textColor
        cell.creditsLabel.textColor = textColor
        cell.itemImage.hnk_setImage(from: DrinkAPI.imageUrlForItem(item))
        cell.itemImage.alpha = alpha

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Do nothing, required for table cell edit actions
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        var saturation : CGFloat = 0.73
        for delay in Array(delayOptions.reversed()) {
            let action = UITableViewRowAction(style: .default, title: "\(delay)s") { (rowAction, indexPath) -> Void in
                self.tableView.setEditing(false, animated: true)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.confirmDrop(
                    self.items[(indexPath as NSIndexPath).row],
                    delay: delay,
                    dismiss: {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                )
                Mixpanel.sharedInstance().track("Prompted for delayed drop")
            }
            action.backgroundColor = UIColor(hue: 339.0/359.0, saturation: saturation, brightness: 0.91, alpha: 1.0)
            actions.append(action)
            saturation -= 0.069
        }
        return actions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        confirmDrop(
            self.items[(indexPath as NSIndexPath).row],
            delay: 0,
            dismiss: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        )
        Mixpanel.sharedInstance().track("Prompted for immediate drop")
    }

    func confirmDrop(_ item: Item, delay: Int, dismiss: (() -> (Void))?) {
        var text = "\(item.name) for \(item.humanPrice().lowercased())"
        if delay > 0 {
            text += " in \(delay) " + ("second".pluralize(count: delay))
        }

        let alertview = DrinkAlertView().show(self.view.window!.rootViewController!, title: "Drop Confirmation", text: text, buttonText: "Drop", cancelButtonText: "Cancel")
        alertview.addAction() {
            self.drop(item, delay: delay, completion: dismiss, failure: dismiss)
        }
        alertview.addCancelAction() {
            if let callback = dismiss {
                callback()
            }
        }
    }
    
    func drop(_ item: Item, delay: Int,  completion: (() -> (Void))? = nil, failure: (() -> (Void))? = nil) {
        let text = delay > 0 ? "In \(delay) seconds..." : "Dropping...";
        
        let alertView = DrinkAlertView()
        let droppingView = alertView.show(self.view.window!.rootViewController!, title: "Dropping...", text: text, buttonText: "Ignore")

        if delay > 0 {
            updateCountdown(droppingView.alertview, time: delay - 1) // TODO: this seems broken, could be refactored
        }

        DrinkAPI.dropItem(item, delay: delay,
            completion: { data in
                CurrentUser.updateUser()
                alertView.closeAction = {
                    _ = DrinkAlertView().show(self.view.window!.rootViewController!, title: "Dropped!", text: "Item successfully dropped!", buttonText: "OK")
                }
                alertView.closeView(true)
            }, failure: { error, message in
                alertView.closeView(true)
                alertView.closeAction = {
                    _ = DrinkAlertView().show(self.view.window!.rootViewController!, title: "Drop Failed", text: message ?? "Your item failed to drop", buttonText: "OK")
                }
            }
        )
    }

    func updateCountdown(_ alertView: JSSAlertView, time: Int) {
        delay(1) {
            if !alertView.isAlertOpen {
                return
            } else if time > 0 && alertView.textView.text.range(of: "seconds") != nil {
                alertView.textView.text = "In \(time) seconds..."
                self.updateCountdown(alertView, time: time - 1)
            } else {
                alertView.textView.text = "Dropping..."
            }
        }
    }

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
