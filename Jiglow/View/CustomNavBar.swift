//
//  CustomNavBar.swift
//  JiglowRevised
//
//  Created by Gautier Billard on 22/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

protocol CustomNavBarDelegate {
    func navBarButtonPressed(index: Int)
}

class CustomNavBar: UIView {
    
    private var buttons: [UIButton]!
    private var buttonTitles: [String]!
    private var images = [UIImage]()
    
    var delegate: CustomNavBarDelegate?
    
    var color: UIColor?
    
    convenience init(frame: CGRect, buttonTitles: [String], images: [UIImage]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
        self.images = images
    }
    convenience init(buttonTitles: [String]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.buttonTitles = buttonTitles
    }
    override func draw(_ rect: CGRect) {
        updateView()
    }
    private func configStackView() {
        let backgroundView = UIView(frame: frame)
        backgroundView.roundCorners([.topLeft, .topRight], radius: 12)
        backgroundView.applyGradient()
        backgroundView.alpha = 1
        insertSubview(backgroundView, at: 0)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        
//        let image = [UIImage(systemName: "camera.fill"),UIImage(systemName: "rectangle.stack.fill")]
        
        for index in 0...buttonTitles.count-1 {
            let button = UIButton(type: .system)
//            button.setTitle(buttonTitle, for: .normal)
            button.tintColor = .white
            button.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.setImage(images[index], for: .normal)
            buttons.append(button)
        }
    }
    @objc func buttonAction(_ sender: UIButton!) {
        
        var rank = 0
        
        for (i,btn) in buttons.enumerated() {
            if sender == btn{rank = i}
        }
        
        delegate?.navBarButtonPressed(index: rank)
    }
    func updateView() {
        createButton()
        configStackView()
    }
}
