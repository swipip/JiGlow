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
    
    private let gradientLayer = CAGradientLayer()
    
    private let tapTicResponse = UINotificationFeedbackGenerator()
    
    func setButton() {
        
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.systemYellow.cgColor]
        gradientLayer.startPoint = CGPoint(x:0.0,y: 0)
        gradientLayer.endPoint = CGPoint(x:1, y:0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 25
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        self.layer.cornerRadius = 25
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 5
        
    }
    func animateGradient(startColor: UIColor, endColor: UIColor){
        let gradientAnimation = CABasicAnimation(keyPath: "colors")
        gradientAnimation.duration = 0.5
        gradientAnimation.toValue = [startColor.cgColor, endColor.cgColor]
        gradientAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientAnimation.isRemovedOnCompletion = false
        gradientLayer.add(gradientAnimation, forKey: nil)
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



