//
//  ItemViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    var item: Item!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    
    @IBAction func delaySliderChanged(sender: AnyObject) {
        delayLabel.text = "\(Int(delaySlider.value))"
    }
    
    @IBAction func dropPressed(sender: AnyObject) {
        var message: String
        if delaySlider.value > 0 {
            message = "Your item will drop in \(Int(delaySlider.value)) seconds"
        }
        else {
            message = "Your item is being dropped!"
        }
        var dropAlert = UIAlertController(title: "Item Dropped", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dropAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(dropAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        priceLabel.text = "\(item.price) Credit" + (item.price == 1 ? "" : "s")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
