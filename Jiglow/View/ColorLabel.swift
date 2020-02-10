//
//  ColorLabel.swift
//  Jiglow
//
//  Created by Gautier Billard on 07/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit



class ColorLabel: UILabel {
    
    
    var red: CGFloat?
    var green: CGFloat?
    var blue: CGFloat?
    
    func animateOn(toColor: UIColor) {
        
        UIView.animate(withDuration: 0.0, animations: {
            self.textColor = toColor
        }, completion: nil)
        
    }

    
}
