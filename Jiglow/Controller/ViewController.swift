import UIKit

class ViewController: UIViewController, PalletDelegate,SwipeControllerDelegate,UIGestureRecognizerDelegate {

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
    
    //    var tile: Tile?
    var descriptionLabel: ColorLabel?
    var subviewCallOut = SliderCallout()
    var testView: SliderCallout?
    var pallet = Pallet()
    var tileWidth: CGFloat = 0.0
    
    var longPressGestureTopTile: UILongPressGestureRecognizer?
    var longPressGestureSecondTile: UILongPressGestureRecognizer?
    var longPressGestureThirdTile: UILongPressGestureRecognizer?
    var longPressGestureBottomTile: UILongPressGestureRecognizer?
    var longPressGestureStack: UILongPressGestureRecognizer?
    var longPressGestureReset: UILongPressGestureRecognizer?
    
    public var miniPallets = [miniPallet]()
    
    var swipeController: SwipeController?
    var originS: CGPoint?
    var currentS = CGPoint()
    //MARK: - Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeController = SwipeController(view: self.view)
        swipeController?.delegate = self
        
        btnReset.setButton()
        btnCamera.layer.cornerRadius = 25
        btnStack.layer.cornerRadius = 25
        
        addParallaxToView(vw: btnReset)
        
        sliderRed.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderGreen.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderBlue.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        palletSetUp()
        palletSetUp()
        
        
        
        addParallaxToView(vw: pallet)
        
        longPressGestureStack = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureStack?.minimumPressDuration = 0.0
        longPressGestureReset = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureReset?.minimumPressDuration = 0.0
        
        btnStack.addGestureRecognizer(longPressGestureStack!)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    @objc func panHandler(recognizer: UIPanGestureRecognizer){
        swipeController?.handlePan(recognizer: recognizer)
    }
    override func viewDidLayoutSubviews() {
        layoutPallet()
    }
    override func viewDidAppear(_ animated: Bool) {
        //        layoutPallet()
    }
    func layoutPallet(){
        //        print(swipeController?.squares.count)
        pallet = (swipeController?.squares[1])!
        pallet.delegate = self
        for pallet in swipeController!.squares{
            pallet.topTile.roundCorners(corners: [.topRight, .topLeft], radius: 18)
            pallet.bottomTile.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 18)
            pallet.layer.shadowRadius = 5.23
            pallet.layer.shadowOpacity = 0.23
        }
        
        tileWidth = pallet.topTile.frame.width
        
        originS = CGPoint(x: self.view.center.x , y: self.view.center.y - pallet.frame.height/2 - 20)
        swipeController!.squares[0].alpha = 0.0
        
        swipeController!.originS = self.originS
        swipeController!.currentS = self.currentS
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
    
    //MARK: - Pallet SetUp
    func palletSetUp() {
        
        let newPallet = Pallet()
        
        swipeController?.squares.append(newPallet)
        
        view.addSubview(newPallet)
        newPallet.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newPallet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            newPallet.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            newPallet.widthAnchor.constraint(equalToConstant: 264),
            newPallet.heightAnchor.constraint(equalToConstant: 277)
        ])
        
        let palletPan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(recognizer:)))
        newPallet.addGestureRecognizer(palletPan)
        
    }
    //MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToColorDetail" {
            prepareForDetails(with: segue, with: sender)
        }else if segue.identifier == "mainToCollection" {
            prepareForCollection(with: segue, with: sender)
        }
    }
    func prepareForCollection(with segue: UIStoryboardSegue,with sender: Any?) {
                if let viewController = segue.destination as? CollectionController {
                    viewController.miniPallets = self.miniPallets
                }
    }
    func saveTile(){
        let newMiniPallet = miniPallet()
        newMiniPallet.topTileColor = pallet.topTile.contentView.backgroundColor!
        
        //                print("prepare for segue :\(pallet.topTile.contentView.backgroundColor)")
        newMiniPallet.secondTileColor = pallet.secondTile.contentView.backgroundColor!
        newMiniPallet.thirdTileColor = pallet.thirdTile.contentView.backgroundColor!
        newMiniPallet.bottomTileColor = pallet.bottomTile.contentView.backgroundColor!
        
        miniPallets.append(newMiniPallet)
        
    }
    func prepareForDetails(with segue: UIStoryboardSegue,with sender: Any?){
        if let viewController = segue.destination as? ColorDetailControler {
            viewController.delegate = self
            if let safeTile = pallet.activeTile {
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
    //MARK: - IBActions
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
            pallet.activeTile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            pallet.activeTile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)
            pallet.activeTile?.hexaLabel.text = pallet.activeTile?.contentView.backgroundColor?.toHexString()
            
        case "sldGreen":
            green = CGFloat(sender.value)
            testView?.calloutLabel.text = String(Int(sender.value * 255))
            testView?.calloutLabel.animateOn(toColor: UIColor(displayP3Red: 0, green: CGFloat(sender.value), blue: 0, alpha: 1))
            animateSliderCallOut(sender: testView!, xCoordinate: xCoordinate)
            pallet.activeTile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            pallet.activeTile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)
            pallet.activeTile?.hexaLabel.text = pallet.activeTile?.contentView.backgroundColor?.toHexString()
            
        case "sldBlue":
            self.blue = CGFloat(sender.value)
            testView?.calloutLabel.text = String(Int(sender.value * 255))
            testView?.calloutLabel.animateOn(toColor: UIColor(displayP3Red: 0, green: 0, blue: CGFloat(sender.value), alpha: 1))
            animateSliderCallOut(sender: testView!, xCoordinate: xCoordinate)
            pallet.activeTile?.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
            pallet.activeTile?.hexaLabel.prepareColor(red: red, green: green, blue: blue)
            pallet.activeTile?.hexaLabel.text = pallet.activeTile?.contentView.backgroundColor?.toHexString()
        default:
            print("error")
        }
        
    }
    @IBAction func resetClicked(_ sender: UIButton) {
        pallet.topTile.contentView.backgroundColor = .lightGray
        pallet.secondTile.contentView.backgroundColor = .gray
        pallet.thirdTile.contentView.backgroundColor = .darkGray
        pallet.bottomTile.contentView.backgroundColor = .black
        
        btnReset.animateGradient(startColor: .darkGray, endColor: .lightGray)
        
        pallet.activeTile?.transformOff()
        pallet.activeTile?.animateLabelAlphaOff()
        pallet.activeTile?.tileIsActive = false
        pallet.activeTile = nil
    }
    //MARK: - Animations
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
    func animateSliderCallOut(sender: UIView, xCoordinate: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            sender.frame = CGRect(x: xCoordinate, y: (sender.frame.origin.y), width: CGFloat(50), height: CGFloat(30))
            
        }, completion: nil)
    }
    func animateSliders(tile: Tile) {
        
        red = (tile.contentView.backgroundColor?.rgb()!.red)!
        green = (tile.contentView.backgroundColor?.rgb()!.green)!
        blue = (tile.contentView.backgroundColor?.rgb()!.blue)!
        
        tile.hexaLabel.text = tile.contentView.backgroundColor?.toHexString()
        
        UIView.animate(withDuration: 0.63, delay: 0,options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.sliderRed.setValue(Float(self.red), animated: true)
            self.sliderGreen.setValue(Float(self.green), animated: true)
            self.sliderBlue.setValue(Float(self.blue), animated: true)
        }, completion: nil)
    }
    //MARK: - Delegate Methods
    func panDidEnd() {
        saveTile()
    }
    
    func didFinishedAnimateReload() {
        palletSetUp()
    }
    func shortPressOccured() {
        if pallet.activeTile != nil{
            animateSliders(tile: pallet.activeTile!)
        }
    }
    func longPressOccured() {
        //Vibrate
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
        //Logic
        if let safeTile = pallet.activeTile {
            safeTile.hexaCode = safeTile.contentView.backgroundColor?.toHexString()
            safeTile.redCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.red)! * 255))
            safeTile.greenCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.green)! * 255))
            safeTile.blueCode = String(describing: Int((safeTile.contentView.backgroundColor?.rgb()!.blue)! * 255))
            //
        }
        performSegue(withIdentifier: "mainToColorDetail", sender: Any?.self)
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
        pallet.activeTile?.transformOff()
        pallet.activeTile?.tileIsActive = false
        pallet.activeTile = nil
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



