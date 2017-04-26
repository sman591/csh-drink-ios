//
//  ItemTableViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Haneke
import Mixpanel

class ItemTableViewController: UITableViewController {

    let delayOptions = [10, 20, 30, 45, 60]
    
    var machines = [Machine]()
    
    @IBOutlet weak var creditsOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Machines"

        if !CurrentUser.isLoggedIn() {
            self.performSegue(withIdentifier: "goto_login", sender: self)
        }
        
        CurrentUser.sharedInstance.credits.bindAndFire {
            [unowned self] in
            self.creditsOutlet.title = "\($0) " + ("credit".pluralize(count: $0))
        }
        
        
        updateMachines()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ItemTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        Mixpanel.sharedInstance().track("Opened machine item list")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.machines.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.machines[section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.machines[section].items.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarItem.image = UIImage(named: "drink-outline")
        self.tabBarItem.selectedImage = UIImage(named: "drink")
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView?, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        let item = self.machines[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = item.name
        cell.creditsLabel.text = item.humanPrice()
        
        var textColor: UIColor
        var alpha: CGFloat
        
        var errorText: String?
        
        if !item.enabled() {
            errorText = "Unavailable"
        } else if !CurrentUser.canAffordItem(item) {
            errorText = "Insufficient funds"
        } else {
            errorText = nil
        }
        
        if errorText == nil {
            alpha = 1
            textColor = UIColor(white: 0.29, alpha: alpha)
            cell.isUserInteractionEnabled = true
            cell.errorLabel.removeFromSuperview()
        } else {
            alpha = 0.25
            textColor = UIColor(white: 0.29, alpha: alpha)
            cell.isUserInteractionEnabled = false
            cell.errorLabel.text = errorText
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
                    self.machines[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row],
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
            self.machines[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row],
            delay: 0,
            dismiss: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        )
        Mixpanel.sharedInstance().track("Prompted for immediate drop")
    }

    func confirmDrop(_ item: Item, delay: Int, dismiss: (() -> (Void))?) {
        var text = item.humanPrice().lowercased()
        if delay > 0 {
            text += " in \(delay) " + ("second".pluralize(count: delay))
        }

        let alertview = DrinkAlertView().show(self.view.window!.rootViewController!, title: item.name, text: text, buttonText: "Drop", cancelButtonText: "Cancel")
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

        DrinkAPI.dropItem(item: item, delay: delay,
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
    
    func refresh(_ sender: AnyObject) {
        updateMachines()
        CurrentUser.updateUser()
    }
    
    func updateMachines() {
        var machines = [Machine]()
        DrinkAPI.getMachinesStock(completion: { data in
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
                    items.sort(by: { $0.enabled() && !$1.enabled() })
                    machines.append(Machine(name: machine[0]["display_name"].stringValue, items: items))
                }
            }
            machines.sort(by: { $0.items.count < $1.items.count })
            self.machines = machines
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }, failure: { error, message in
            self.refreshControl?.endRefreshing()
            DrinkAPI.genericApiError(self.view.window!.rootViewController!, message: message)
        })
    }
    
}
