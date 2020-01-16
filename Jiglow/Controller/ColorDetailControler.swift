//
//  ColorDetailControler.swift
//  Jiglow
//
//  Created by Gautier Billard on 08/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

protocol ColorDetailControlerDelegate {
    func colorDetailDelegateDidDisapear()
}

class ColorDetailControler: UIViewController {
    
    var delegate: ColorDetailControlerDelegate?
    
    @IBOutlet var colorView: UIView!
    @IBOutlet weak var secondColor1: UIView!
    @IBOutlet weak var secondColor2: UIView!
    @IBOutlet weak var secondColor3: UIView!
    @IBOutlet weak var lblHexaCode: UILabel!
    @IBOutlet weak var lblRed: UILabel!
    @IBOutlet weak var lblGreen: UILabel!
    @IBOutlet weak var lblBlue: UILabel!
    
    var mainColor: UIColor?
    var leftColor: UIColor?
    var middleColor: UIColor?
    var rightColor: UIColor?
    var hexaCode: String?
    var redCode: String?
    var greenCode: String?
    var blueCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDetailController()
        

    }
    func setUpDetailController() {
        
        colorView.backgroundColor = mainColor
        secondColor1.backgroundColor = leftColor
        secondColor2.backgroundColor = middleColor
        secondColor3.backgroundColor = rightColor
        lblHexaCode.text = hexaCode
        lblHexaCode.textColor = mainColor
//        addParallaxToView(vw: lblHexaCode)
        lblRed.text = redCode
        lblGreen.text = greenCode
        lblBlue.text = blueCode
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.delegate?.colorDetailDelegateDidDisapear()

    }
}
