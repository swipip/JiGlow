//
//  miniPallet.swift
//  Jiglow
//
//  Created by Gautier Billard on 16/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class miniPallet: UICollectionViewCell {

    
    @IBOutlet weak var tileStack: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        tileStack.clipsToBounds = true
        tileStack.layer.cornerRadius = 8
    }

}
