//
//  CustomSegmentedControl.swift
//  testPickerView
//
//  Created by Gautier Billard on 19/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class TwoegmentedControl: UIView {

    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectorView: UIView!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var selectorWidth: CGFloat = 0
    private var opposedConstraint: CGFloat = 0
    private var isRight = false
    
    var inset:CGFloat = 5
    var textColor: UIColor = .black
    var selectorViewColor: UIColor = .systemYellow
    var backgroudViewColor: UIColor = .systemRed
    var selectorTextCOlor: UIColor = .white
    
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
        selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        opposedConstraint = frame.width - selectorWidth
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }

    private func configStackView() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroudViewColor
        backgroundView.layer.cornerRadius = frame.size.height / 2
        
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
    private func configSelectorView() {
        
        let height = self.frame.size.height - inset*2
        
        selectorView = UIView()//UIView(frame: CGRect(x: inset, y: inset, width: selectorWidth - inset*2, height: height))
        selectorView.layer.cornerRadius = height / 2
        selectorView.backgroundColor = selectorViewColor
        
        addSubview(selectorView)
        
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([selectorView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                                     selectorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)])
        
        leadingConstraint = NSLayoutConstraint(item: selectorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: inset)
        trailingConstraint = NSLayoutConstraint(item: selectorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -opposedConstraint)
        
        addConstraints([leadingConstraint,trailingConstraint])

    }
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            
            button.setTitleColor(textColor, for: .normal)
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectorTextCOlor, for: .normal)
    }
    @objc func buttonAction(_ sender: UIButton!) {
        for btn in buttons {
            btn.setTitleColor(textColor, for: .normal)
            if btn == sender {
//                let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                
                let animationTime = 0.3
                
                UIView.animate(withDuration: animationTime/2, delay: 0, options: .curveEaseIn, animations: {
                    self.leadingConstraint.constant = self.isRight == true ? self.inset : self.inset + 30
                    self.trailingConstraint.constant = self.isRight == true ? -self.inset - 30: -self.inset
                    self.layoutIfNeeded()
                }) { (ended) in
                    UIView.animate(withDuration: animationTime/2, delay: 0, options: .curveEaseOut, animations:  {
                        self.leadingConstraint.constant = self.isRight == true ? self.opposedConstraint  : -self.inset*0.8
                        self.trailingConstraint.constant = self.isRight == true ? self.inset*0.8 : -self.opposedConstraint
                        self.layoutIfNeeded()
                    }) { (ended) in
                        UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut, animations:  {
                            self.leadingConstraint.constant = self.isRight == true ? self.opposedConstraint  : self.inset
                            self.trailingConstraint.constant = self.isRight == true ? -self.inset : -self.opposedConstraint
                            self.layoutIfNeeded()
                        }) { (ended) in
                            
                        }
                    }
                }
                
                self.isRight.toggle()

                btn.setTitleColor(selectorTextCOlor, for: .normal)
            }
        }
    }
    private func updateView() {
        createButton()
        configSelectorView()
        configStackView()
    }
}
