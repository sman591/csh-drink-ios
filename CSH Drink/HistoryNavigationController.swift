//
//  DropNavigationController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 4/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class HistoryNavigationController: UINavigationController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.image = UIImage(named: "history-tab-bar-empty")
        self.tabBarItem.selectedImage = UIImage(named: "history-tab-bar-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
