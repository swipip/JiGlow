//
//  RadialGradientView.swift
//  Jiglow
//
//  Created by Gautier Billard on 05/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

@IBDesignable
class RadialGradientView: UIView {

    @IBInspectable var insideColor: UIColor = UIColor.red
    @IBInspectable var outSideColor: UIColor = UIColor.clear
    @IBInspectable var radius: CGFloat = 0.0
    @IBInspectable var right = true
    
    override func draw(_ rect: CGRect) {
        
        if right {
            let colors = [insideColor.cgColor,outSideColor.cgColor] as CFArray
            
            let center = CGPoint(x: bounds.size.width + 100,y: bounds.size.height/2)
            
            //        let endRadius = min(frame.width, frame.height)
            
            let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
            
            UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        }else{
            let colors = [insideColor.cgColor,outSideColor.cgColor] as CFArray
            
            let center = CGPoint(x: -100,y: bounds.size.height/2)
            
            //        let endRadius = min(frame.width, frame.height)
            
            let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
            
            UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        }
        

        
    }
    
}
