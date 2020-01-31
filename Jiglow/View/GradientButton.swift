//
//  GradientButton.swift
//  Jiglow
//
//  Created by Gautier Billard on 06/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

class GradientButton: UIButton {
    
//    var color: UIColor?
    
    private var gradientLayer: CAGradientLayer?
    
    private let tapTicResponse = UINotificationFeedbackGenerator()
    
    func setButton() {
        
        setButtonGradient()
        
        self.layer.cornerRadius = 25
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 5
        
    }
    private func setButtonGradient() {
        
        gradientLayer = CAGradientLayer()
        if let safeLayer = gradientLayer {
            safeLayer.colors = [UIColor.orange.cgColor, UIColor.systemYellow.cgColor]
            safeLayer.startPoint = CGPoint(x:0.0,y: 0)
            safeLayer.endPoint = CGPoint(x:1, y:0)
            safeLayer.frame = self.bounds
            safeLayer.cornerRadius = 25
            self.layer.insertSublayer(safeLayer, at: 0)
        }

    }
    func animateGradient(startColor: UIColor, endColor: UIColor = .systemOrange){
        
        let color1 = startColor.darken(by: 15)!.cgColor
        let color2 = startColor.lighten(by: 5)!.cgColor
        
        if let gl = gradientLayer {
            
            UIView.animate(withDuration: 0.34) {
                gl.colors = [color1,color2]
            }
            
        }
    }
    func animateSizeOn() {
        
        tapTicResponse.notificationOccurred(.success)
        
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseOut,animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                   },completion: nil)
        
        
    }
    func animateSizeOff() {
        
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseOut,animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
                   },completion: nil)
        
    }

}



