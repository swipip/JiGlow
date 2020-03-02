//
//  CustomSegmentedControl.swift
//  testPickerView
//
//  Created by Gautier Billard on 19/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
protocol TwoSegmentControlDelegate {
    func didChoose(option: String)
}
class TwoSegmentControl: UIView {

    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectorView: UIView!
    private var selectorWidth: CGFloat = 0
    private var opposedConstraint: CGFloat = 0
    
    var inset:CGFloat = 5
    var textColor: UIColor = .white
    var selectorViewColor: UIColor = .systemYellow
    var backgroudViewColor: UIColor = .systemRed
    var selectorTextCOlor: UIColor = .white
    
    var delegate: TwoSegmentControlDelegate?
    
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
    }
    convenience init(buttonTitles: [String]) {
        self.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.buttonTitles = buttonTitles
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    private func configStackView() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        backgroundView.layer.cornerRadius = frame.size.height / 2
        backgroundView.alpha = 0.6
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.white.cgColor
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
        
        selectorView = UIView(frame: CGRect(x: inset, y: inset, width: selectorWidth - inset*2, height: height))
        selectorView.layer.cornerRadius = height / 2
        selectorView.backgroundColor = selectorViewColor
        selectorView.alpha = 0.9
        
        addSubview(selectorView)

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
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == sender {
                let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.12, options: .curveEaseInOut, animations: {
                    self.selectorView.frame.origin.x = selectorPosition + self.inset
                }, completion: {(ended) in
                    self.delegate?.didChoose(option: btn.titleLabel?.text ?? "error")
                })

                btn.setTitleColor(selectorTextCOlor, for: .normal)
            }
        }
    }
    func updateView() {
        selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        opposedConstraint = frame.width - selectorWidth
        createButton()
        configSelectorView()
        configStackView()
    }
}
