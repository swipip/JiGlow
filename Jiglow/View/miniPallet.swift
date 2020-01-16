//
//  miniPallet.swift
//  Jiglow
//
//  Created by Gautier Billard on 16/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class miniPallet: UICollectionViewCell {

    
    @IBOutlet private weak var tileStack: UIView!
    @IBOutlet private weak var topTile: UIView!
    @IBOutlet private weak var secondTile: UIView!
    @IBOutlet private weak var thirdTile: UIView!
    @IBOutlet private weak var bottomTile: UIView!
    
    var topTileColor: UIColor?
    var secondTileColor: UIColor?
    var thirdTileColor: UIColor?
    var bottomTileColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tileStack.clipsToBounds = true
        tileStack.layer.cornerRadius = 8
        
    }
    func updateColor(top: UIColor, second:UIColor, third: UIColor, bottom: UIColor) {
        
        topTile.backgroundColor = top
//        print(topTileColor)
        secondTile.backgroundColor = second
        thirdTile.backgroundColor = third
        bottomTile.backgroundColor = bottom
        
    }

}
