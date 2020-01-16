import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
    @IBOutlet weak var btnReset: GradientButton!
    @IBOutlet var superView: UIView!
    @IBOutlet weak var slidersStackView: UIStackView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnStack: GradientButton!
    
    //MARK: - Variables
    
    var red: CGFloat = 0.5
    var green: CGFloat = 0.5
    var blue: CGFloat = 0.5
    var btnColorOne: UIColor = .orange
    var btnColorTwo: UIColor = .systemYellow
    
    var tile: Tile?
    var descriptionLabel: ColorLabel?
    var subviewCallOut = SliderCallout()
    var testView: SliderCallout?
    let pallet = Pallet()
    var tileWidth: CGFloat = 0.0
    
    var longPressGestureTopTile: UILongPressGestureRecognizer?
    var longPressGestureSecondTile: UILongPressGestureRecognizer?
    var longPressGestureThirdTile: UILongPressGestureRecognizer?
    var longPressGestureBottomTile: UILongPressGestureRecognizer?
    var longPressGestureStack: UILongPressGestureRecognizer?
    var longPressGestureReset: UILongPressGestureRecognizer?
    
    //MARK: - Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReset.setButton()
        btnCamera.layer.cornerRadius = 25
        btnStack.layer.cornerRadius = 25
        
        addParallaxToView(vw: btnReset)
        
        sliderRed.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderGreen.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderBlue.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        palletSetUp()
        
        addParallaxToView(vw: pallet)
        
        longPressGestureStack = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureStack?.minimumPressDuration = 0.0
        longPressGestureReset = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureReset?.minimumPressDuration = 0.0
        
        btnStack.addGestureRecognizer(longPressGestureStack!)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        pallet.topTile.roundCorners(corners: [.topRight, .topLeft], radius: 18)
        pallet.bottomTile.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 18)
        pallet.layer.shadowRadius = 5.23
        pallet.layer.shadowOpacity = 0.23
        
        tileWidth = pallet.topTile.frame.width
    }
    //MARK: - Gestures Handlers
    @objc func stackLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began{
            
            btnStack.animateSizeOn()
            performSegue(withIdentifier: "mainToCollection", sender: self)
            
        }else if sender.state == .ended{
            
            btnStack.animateSizeOff()
            
        }
        
    }
    @IBAction func stackTouched(_ sender: Any) {
        
        performSegue(withIdentifier: "mainToCollection", sender: self)
        
    }
    @objc func tapHandler(sender: AnyObject) {
            if let safeSender = sender as? UITapGestureRecognizer{
                switch self.tile {
                case nil:
                    self.tile = safeSender.view! as? Tile
                    animateSliders(tile: self.tile!)
                    self.tile?.transformTile(tile: self.tile! ,initialWidth: tileWidth)
                case safeSender.view:
                    self.tile?.transformTile(tile: self.tile! ,initialWidth: tileWidth)
                    self.tile = nil
                default:
                    self.tile?.transformTile(tile: self.tile! ,initialWidth: tileWidth)
                    btnColorOne = tile!.contentView.backgroundColor!
                    self.tile = safeSender.view as? Tile
                    animateSliders(tile: self.tile!)
                    self.tile?.transformTile(tile: self.tile! ,initialWidth: tileWidth)
                    btnColorTwo = tile!.contentView.backgroundColor!
                    btnReset.animateGradient(startColor: btnColorOne, endColor: btnColorTwo)
                }
            }
        }
        @objc func longPressHandler(sender: AnyObject) {
            if let safeSender = sender as? UILongPressGestureRecognizer {
                if safeSender.state == .began {
                    
                    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                    notificationFeedbackGenerator.prepare()
                    notificationFeedbackGenerator.notificationOccurred(.success)
                    
                    tile = safeSender.view! as? Tile
                    
                    if let safeTile = tile {
                        safeTile.hexaCode = safeTile.contentView.backgroundColor?.toHexString()
                        safeTile.redCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.red)! * 255))
                        safeTile.greenCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.green)! * 255))
                        safeTile.blueCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.blue)! * 255))
                        //
                        safeTile.transformTile(tile: safeTile, initialWidth: tileWidth)
                    }
                    performSegue(withIdentifier: "mainToColorDetail", sender: Any?.self)
                }
            }
        }
    //MARK: - Pallet SetUp
    func palletSetUp() {
        
        view.addSubview(pallet)
        pallet.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pallet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pallet.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            pallet.widthAnchor.constraint(equalToConstant: 264),
            pallet.heightAnchor.constraint(equalToConstant: 277)
        ])
        
        let topTileTouch = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let secondTileTouch = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let thirdTileTouch = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let bottomTileTouch = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        
        pallet.topTile.addGestureRecognizer(topTileTouch)
        pallet.secondTile.addGestureRecognizer(secondTileTouch)
        pallet.thirdTile.addGestureRecognizer(thirdTileTouch)
        pallet.bottomTile.addGestureRecognizer(bottomTileTouch)
        
        longPressGestureTopTile = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressHandler))
        longPressGestureSecondTile = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressHandler))
        longPressGestureThirdTile = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressHandler))
        longPressGestureBottomTile = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressHandler))
        
        pallet.topTile.addGestureRecognizer(longPressGestureTopTile!)
        pallet.secondTile.addGestureRecognizer(longPressGestureSecondTile!)
        pallet.thirdTile.addGestureRecognizer(longPressGestureThirdTile!)
        pallet.bottomTile.addGestureRecognizer(longPressGestureBottomTile!)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToColorDetail" {
            if let viewController = segue.destination as? ColorDetailControler {
                viewController.delegate = self
                if let safeTile = tile {
                    viewController.mainColor = safeTile.contentView.backgroundColor ?? .black
                    viewController.hexaCode = safeTile.hexaCode
                    viewController.redCode = safeTile.redCode
                    viewController.greenCode = safeTile.greenCode
                    viewController.blueCode = safeTile.blueCode
                    switch safeTile.rank {
                    case 1:
                        viewController.leftColor = pallet.secondTile.contentView.backgroundColor
                        viewController.middleColor = pallet.thirdTile.contentView.backgroundColor
                        viewController.rightColor = pallet.bottomTile.contentView.backgroundColor
                    case 2:
                        viewController.leftColor = pallet.topTile.contentView.backgroundColor
                        viewController.middleColor = pallet.thirdTile.contentView.backgroundColor
                        viewController.rightColor = pallet.bottomTile.contentView.backgroundColor
                    case 3:
                        viewController.leftColor = pallet.topTile.contentView.backgroundColor
                        viewController.middleColor = pallet.secondTile.contentView.backgroundColor
                        viewController.rightColor = pallet.bottomTile.contentView.backgroundColor
                    case 4:
                        viewController.leftColor = pallet.topTile.contentView.backgroundColor
                        viewController.middleColor = pallet.secondTile.contentView.backgroundColor
                        viewController.rightColor = pallet.thirdTile.contentView.backgroundColor
                    default:
                        break
                    }
                }
            }
        }
    }
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .ended:
                UIView.animate(withDuration: 0.66 ,delay: 0.0, animations: {
                    self.testView?.alpha = 0
                }) { (finished: Bool) in
                    self.testView?.removeFromSuperview()
                    self.testView = nil
                }
            default:
                break
            }
        }
    }
    @IBAction func sliderSlide(_ sender: UISlider) {
        
        let sliderCoordinates = superView.convert(sender.frame, from:sliderRed)
        let xCoordinate = sender.thumbCenterX + 36
        let yCoordinate = sliderCoordinates.origin.y - CGFloat(30)
        
        if testView != nil {
            testView?.alpha += 0.05
        }else{
            testView = SliderCallout()
            testView?.frame.size = CGSize(width: 50, height: 30)
            testView?.frame.origin.x = xCoordinate
            testView?.frame.origin.y = yCoordinate
            testView?.alpha = 0
            
            superView.addSubview(testView!)
        }
        switch sender.accessibilityIdentifier {
        case "sldRed":
            red = CGFloat(sender.value)
            testView?.calloutLabel.text = String(Int(sender.value * 255))
            testView?.calloutLabel.animateOn(toColor: UIColor(displayP3Red: CGFloat(sender.value), green: 0, blue: 0, alpha: 1))
            animateSliderCallOut(sender: testView!, xCoordinate: xCoordinate)
            tile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            tile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)

        case "sldGreen":
            green = CGFloat(sender.value)
            testView?.calloutLabel.text = String(Int(sender.value * 255))
            testView?.calloutLabel.animateOn(toColor: UIColor(displayP3Red: 0, green: CGFloat(sender.value), blue: 0, alpha: 1))
            animateSliderCallOut(sender: testView!, xCoordinate: xCoordinate)
            tile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            tile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)

            
        case "sldBlue":
            self.blue = CGFloat(sender.value)
            testView?.calloutLabel.text = String(Int(sender.value * 255))
            testView?.calloutLabel.animateOn(toColor: UIColor(displayP3Red: 0, green: 0, blue: CGFloat(sender.value), alpha: 1))
            animateSliderCallOut(sender: testView!, xCoordinate: xCoordinate)
            self.tile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            tile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)
        default:
            print("error")
        }
        
    }
    func animateSliderCallOut(sender: UIView, xCoordinate: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            sender.frame = CGRect(x: xCoordinate, y: (sender.frame.origin.y), width: CGFloat(50), height: CGFloat(30))
            
        }, completion: nil)
    }
    @IBAction func resetClicked(_ sender: UIButton) {
        pallet.topTile.contentView.backgroundColor = .lightGray
        pallet.secondTile.contentView.backgroundColor = .gray
        pallet.thirdTile.contentView.backgroundColor = .darkGray
        pallet.bottomTile.contentView.backgroundColor = .black
        
        btnReset.animateGradient(startColor: .darkGray, endColor: .lightGray)
    }
    func animateSliders(tile: Tile) {
        
        red = (tile.contentView.backgroundColor?.rgb()!.red)!
        green = (tile.contentView.backgroundColor?.rgb()!.green)!
        blue = (tile.contentView.backgroundColor?.rgb()!.blue)!
        
        UIView.animate(withDuration: 0.63, delay: 0,options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.sliderRed.setValue(Float(self.red), animated: true)
            self.sliderGreen.setValue(Float(self.green), animated: true)
            self.sliderBlue.setValue(Float(self.blue), animated: true)
        }, completion: nil)
    }
}
//MARK: - General functions
public func addParallaxToView(vw: UIView) {
    let amount = 17
    
    let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    horizontal.minimumRelativeValue = -amount
    horizontal.maximumRelativeValue = amount
    
    let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    vertical.minimumRelativeValue = -amount
    vertical.maximumRelativeValue = amount
    
    let group = UIMotionEffectGroup()
    group.motionEffects = [horizontal, vertical]
    vw.addMotionEffect(group)
}
//MARK: - Extensions
extension ViewController: ColorDetailControlerDelegate{
    func colorDetailDelegateDidDisapear() {
        if (tile?.frame.width)! > tileWidth{
            tile?.transformTile(tile: tile!, initialWidth: tileWidth)
        }
        tile = nil
    }
}
extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = (fRed)
            let iGreen = (fGreen)
            let iBlue = (fBlue)
            let iAlpha = (fAlpha)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}



