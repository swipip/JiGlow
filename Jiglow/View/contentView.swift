//
//  squareTest.swift
//  Jiglow
//
//  Created by Gautier Billard on 09/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class squareTest: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var innerSquare: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("fatal error")
    }
    func setUp() {
        Bundle.main.loadNibNamed("squareTest", owner: self, options: nil)
        
        addSubview(contentView)
        
        contentView.frame = self.bounds
    }

}
