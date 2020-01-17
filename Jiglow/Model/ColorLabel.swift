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
    func prepareColor(red: CGFloat, green: CGFloat, blue: CGFloat){
        if red < 0.1 || green < 0.1 || blue < 0.1 {
            
            self.textColor = UIColor(displayP3Red: red + 0.5, green: green + 0.5, blue: blue + 0.5, alpha: 1)
            
        }else{
            self.textColor = UIColor(displayP3Red: red - 0.12, green: green - 0.12, blue: blue - 0.12, alpha: 1)
        }
    }
    
}
