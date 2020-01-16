//
//  Tile.swift
//  Jiglow
//
//  Created by Gautier Billard on 06/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

class Tile: UIView {
    
    var hexaCode: String?
    var redCode: String?
    var blueCode: String?
    var greenCode: String?
    var color: UIColor?
    var rank: Int?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var hexaLabel: ColorLabel!
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    func commonInit() {
        Bundle.main.loadNibNamed("Tile", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
    }
    
    //MARK: - Custom Methods
    
    func transformTile(tile: Tile, initialWidth: CGFloat) {
        if (self.frame.width) > CGFloat(initialWidth) {
            UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseOut,animations: {
                tile.transform = CGAffineTransform(scaleX: 1, y: 1)
                tile.contentView.layer.cornerRadius = 0
            },completion: nil)
            return
        }else{
            //            roundedView.bringSubviewToFront(self.tile!)
            UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseOut,animations: {
                tile.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                tile.contentView.layer.cornerRadius = 10
            },completion: nil)
            return
        }
    }
    
}

//MARK: - Extensions

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

}
