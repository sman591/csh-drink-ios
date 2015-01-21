//
//  DrinkViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class DrinkViewController: UIViewController {

    var drink: Drink!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func dropPressed(sender: AnyObject) {
        var dropAlert = UIAlertController(title: "Drink Dropped", message: "Your drink has been dropped!", preferredStyle: UIAlertControllerStyle.Alert)
        dropAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(dropAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        priceLabel.text = String(drink.price)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
