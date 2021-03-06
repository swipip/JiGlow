//
//  Extensions.swift
//  JiglowRevised
//
//  Created by Gautier Billard on 22/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

extension UISlider {
    var thumbCenterX: CGFloat {
        return thumbRect(forBounds: frame, trackRect: trackRect(forBounds: frame), value: value).midX
    }
}
extension UILabel {
    func adjustTextColor(color: UIColor) {
        
        if color.getWhiteAndAlpha.white < 0.3 {
            self.textColor = color.lighten()
        }else{
            self.textColor = color.darken(by: 20)
        }
    }
}
extension UIButton {
    func animateAlphaOn() {
        UIView.animate(withDuration: 1) {
            self.alpha = 1
        }
    }
    func animateAlphaOff() {
        UIView.animate(withDuration: 1) {
            self.alpha = 0.0
        }
    }
    func addShadow(radius: CGFloat? = 3.23) {
        let layer = self.layer
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = radius!
        layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        layer.shadowOpacity = 0.2
    }
    func adjustTextColor(color: UIColor) {
        
        if color.getWhiteAndAlpha.white < 0.3 {
            self.tintColor = color.lighten()
        }else{
            self.tintColor = color.darken(by: 20)
        }
    }
}

extension UIView {

    func applyGradient() {
        
        let k = K()
        let color = UIColor(named: k.gradientColor)
        let colors = [color!,color!.withHueOffset(offset: 1/16)]
        
        let gradient = CAGradientLayer()
        gradient.colors = [colors[0].cgColor, colors[1].cgColor]
        gradient.startPoint = CGPoint(x:0.0, y: 1.0)
        gradient.endPoint = CGPoint(x:1.0, y: 0.0)
        gradient.frame = bounds
        gradient.cornerRadius = 12
        
        layer.addSublayer(gradient)//(gradient, at: 1)
    }
    
    func animateAlpha(on: Bool? = true ,withDuration duration: Double? = 0.2) {
        
        UIView.animate(withDuration: duration!) {
            self.alpha = on == true ? 1.0 : 0.0
        }
        
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
extension UIColor {
    
    func lighten(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darken(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
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
    func withHueOffset(offset: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: fmod(h + offset, 1), saturation: s, brightness: b, alpha: a)
    }
    convenience init(hexString: String) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) //1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
