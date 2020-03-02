//
//  Tile.swift
//  JiglowRevised
//
//  Created by Gautier Billard on 22/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

protocol TileDelegate {
    func didTapTile(sender: Tile)
    func didLongPress(sender: Tile)
    func infoButtonPressed(sender: Tile)
}
class Tile: UIView {


    private (set) var infoButton: UIButton!
    
    var delegate: TileDelegate?
    var hexLabelText: String?
    var backColor: UIColor?
    var redCode = 0,greenCode = 0,blueCode = 0
    var hexaCode: String?
    
    var back: UIView!
    var label: UILabel!
    private var height: NSLayoutConstraint!
    private var width: NSLayoutConstraint!
    
    func commonInit() {
        addViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func addViews() {
        addBack()
        addLabel()
        addInfoButton()
        addGestures()
    }
    private func addBack() {
        
        back = UIView()
        
        addSubview(back)
        
        back.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([back.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     back.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
                                     back.topAnchor.constraint(equalTo: topAnchor ,constant: 0),
                                     back.leadingAnchor.constraint(equalTo: leadingAnchor ,constant: 0)])
        
    }
    private func addGestures() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        addGestureRecognizer(tap)
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler))
        longTap.minimumPressDuration = 0.2
        addGestureRecognizer(longTap)
        
    }
    @objc func tapHandler() {
        
        delegate?.didTapTile(sender: self)
        
    }
    @objc func longTapHandler(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {delegate?.didLongPress(sender: self)}
    }
    private func addLabel() {
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "#FFFFFF"
        label.alpha = 0.0
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
    }
    private func addInfoButton() {
        
        infoButton = UIButton()
        infoButton.backgroundColor = .clear
        infoButton.tintColor = .white
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.alpha = 0.0
        
        addSubview(infoButton)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     infoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3),
                                     infoButton.widthAnchor.constraint(equalToConstant: 40),
                                     infoButton.heightAnchor.constraint(equalToConstant: 40)])
        


        
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
    }
    @IBAction func infoButtonPressed(_sender: UIButton!) {
        delegate?.infoButtonPressed(sender: self)
    }
    private func animateInfoButton() {
        var delay = 0.0
        for _ in 1...2 {
            let circle = UIView()
            
            circle.backgroundColor = .clear
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 0.2
            circle.layer.cornerRadius = 10
            self.insertSubview(circle, at: 1)
            
            circle.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([circle.centerYAnchor.constraint(equalTo: self.infoButton.centerYAnchor, constant: 0),
                                         circle.centerXAnchor.constraint(equalTo: self.infoButton.centerXAnchor, constant: 0),
                                         circle.widthAnchor.constraint(equalToConstant: 20),
                                         circle.heightAnchor.constraint(equalToConstant: 20)])
            
            UIView.animate(withDuration: 1.0, delay: delay, options: .curveEaseOut, animations: {
                circle.transform = CGAffineTransform(scaleX: 5, y: 5)
                circle.alpha = 0.0
            }, completion: {(ended) in
                circle.removeFromSuperview()
            })
            delay += 0.1
        }

    }
    func animateElements(on: Bool) {
        
        let alphaValue:CGFloat = on == true ? 1.0 : 0.0
        
        let color = back.backgroundColor
        
        if on == true {animateInfoButton()}
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.12, options: .curveEaseInOut, animations: {
            self.infoButton.adjustTextColor(color: color ?? .white)
            self.infoButton.alpha = alphaValue
            self.label.alpha = alphaValue
            self.label.adjustTextColor(color: color ?? .white)
        }, completion: nil)
        
    }

}
