//
//  DropNavigationController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 4/16/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import UIKit

class DropNavigationController: UINavigationController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.image = UIImage(named: "drink-outline")
        self.tabBarItem.selectedImage = UIImage(named: "drink")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
