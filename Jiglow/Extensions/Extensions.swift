//
//  Extensions.swift
//  Jiglow
//
//  Created by Gautier Billard on 03/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0{
            didSet{
                if r > 1 {
                    r = 1
                }else if r < 0{
                    r = 0
                }
            }
        }
        var g:CGFloat = 0{
            didSet{
                if g > 1 {
                    g = 1
                }else if g < 0{
                    g = 0
                }
            }
        }
        var b:CGFloat = 0{
            didSet{
                if b > 1 {
                    b = 1
                }else if b < 0{
                    b = 0
                }
            }
        }
        var a:CGFloat = 0{
            didSet{
                if a > 1 {
                    a = 1
                }else if a < 0{
                    a = 0
                }
            }
        }
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06X", rgb) as String
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    var getWhiteAndAlpha: (white: CGFloat, alpha: CGFloat) {
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        
        getWhite(&white, alpha: &alpha)
        return(white, alpha)
    }
}
