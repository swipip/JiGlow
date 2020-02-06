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
    func adjustTextColor(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        let color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
        
        if color.getWhiteAndAlpha.white > 0.2 {
            self.textColor = color.lighten()
        }else{
            self.textColor = color.darken()
        }
        
    }
    
}
