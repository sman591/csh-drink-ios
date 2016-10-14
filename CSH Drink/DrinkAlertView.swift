//
//  DrinkAlertView.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 5/24/15.
//  Copyright (c) 2015 Stuart Olivera. All rights reserved.
//

import Foundation
import UIKit

class DrinkAlertView: JSSAlertView {

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        
        self.titleFont = "CriqueGrotesk"
        self.textFont = "CriqueGrotesk"
        self.buttonFont = "CriqueGrotesk"
        self.darkTextColor = lightTextColor
        self.defaultColor = UIColor.drinkPinkColor()
    }

}
