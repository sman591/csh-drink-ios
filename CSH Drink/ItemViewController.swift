//
//  ItemViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 1/21/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ItemViewController: UIViewController {

    var item: Item!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func delaySliderChanged(sender: AnyObject) {
        delayLabel.text = "\(Int(delaySlider.value))"
    }
    
    @IBAction func dropPressed(sender: AnyObject) {
        self.activityIndicator.startAnimating()
        Alamofire.request(.POST, "https://webdrink.csh.rit.edu/api/index.php?request=drops/drop", parameters: [
            "api_key": AuthenticationManager.apiKey,
            "machine_id": item.machine_id,
            "slot_num": item.slot_num,
            "delay": Int(delaySlider.value)]).responseJSON { (_, _, data, _) in
            var json = JSON(data!)
            var message: String
            var title: String
            if json["data"].boolValue == true {
                title = "Item Dropped"
                if self.delaySlider.value > 0 {
                    message = "Your item will drop in \(Int(self.delaySlider.value)) seconds"
                }
                else {
                    message = "Your item is being dropped!"
                }
            } else {
                title = "Drop Failed"
                let failMessage = json["message"].stringValue
                message = "Item failed to drop (\(failMessage))"
            }
            var dropAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            dropAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(dropAlert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        priceLabel.text = "\(item.price) Credit" + (item.price == 1 ? "" : "s")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
