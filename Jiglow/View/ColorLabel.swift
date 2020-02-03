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
    
    func animateColorTransition(red: CGFloat, green: CGFloat, blue: CGFloat){
        //        UIView.animate(withDuration: 1, delay: 1.0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
        //            self.textColor = UIColor(displayP3Red: red + 0.5, green: green + 0.5, blue: blue + 0.5, alpha: 1)
        //        }) { (Bool) in
        //            self.finished = true
        //        }
    }
//    func prepareColor(red: CGFloat, green: CGFloat, blue: CGFloat){
//        if red < 0.1 || green < 0.1 || blue < 0.1 {
//            self.red = max(0, red + 0.5)
//            self.green = max(0, green + 0.5)
//            self.blue = max(0, blue + 0.5)
//            self.textColor = UIColor(displayP3Red: self.red!, green: self.green!, blue: self.blue!, alpha: 1)
//
//        }else{
//            self.red = max(0, red - 0.12)
//            self.green = max(0, green - 0.12)
//            self.blue = max(0, blue - 0.12)
//            self.textColor = UIColor(displayP3Red: self.red!, green: self.green!, blue: self.blue!, alpha: 1)
//        }
//    }
    func adjustTextColor(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        let color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
        
        if color.getWhiteAndAlpha.white > 0.2 {
            self.textColor = color.lighten()
        }else{
            self.textColor = color.darken()
        }
        
    }
    
}
