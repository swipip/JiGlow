import UIKit
import CoreData

class ViewController: UIViewController, PalletDelegate,SwipeControllerDelegate,UIGestureRecognizerDelegate,CollectionControllerDelegate,CAAnimationDelegate {

    
    
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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // variable the model looks to choose between C || U
    var editingMode = false
    
    var red: CGFloat = 0.5
    var green: CGFloat = 0.5
    var blue: CGFloat = 0.5
    var btnColorOne: UIColor = .orange
    var btnColorTwo: UIColor = .systemYellow
    
    var descriptionLabel: ColorLabel?
    var subviewCallOut = SliderCallout()
    var sliderCallOut: SliderCallout?
    var pallet = Pallet()
    var tileWidth: CGFloat = 0.0
    private var tilesColors: (top: String?, second: String?, third: String?, bottom: String?)
    var palletName: String = ""
    var action: UIAlertAction?
    
    var longPressGestureStack: UILongPressGestureRecognizer?
    var longPressGestureReset: UILongPressGestureRecognizer?
    
//    public var miniPallets = [MiniPallet]()
    
    private var miniPalletsCD = [MiniPalletModel]()
    
    var swipeController: SwipeController?
    var originS: CGPoint?
    var currentS = CGPoint()
    //MARK: - Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding
        print(path!)

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
        
        longPressGestureStack = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureStack?.minimumPressDuration = 0.0
        longPressGestureReset = UILongPressGestureRecognizer(target: self, action: #selector(stackLongPress))
        longPressGestureReset?.minimumPressDuration = 0.0
        
        btnStack.addGestureRecognizer(longPressGestureStack!)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationController!.navigationBar.tintColor = .black
        
        let navigationTitleFont = UIFont(name: "Lobster", size: 20)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navigationTitleFont!]
        
    }
    @objc func panHandler(recognizer: UIPanGestureRecognizer){
        swipeController?.handlePan(recognizer: recognizer)
    }
    override func viewDidLayoutSubviews() {
        layoutPallet()
    }
    override func viewDidAppear(_ animated: Bool) {
//        addParallaxToView(vw: pallet)
        
    }
    func layoutPallet(){
        pallet = (swipeController?.squares[1])!
        pallet.delegate = self
        for pallet in swipeController!.squares{
            pallet.topTile.roundCorners(corners: [.topRight, .topLeft], radius: 18)
            pallet.bottomTile.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 18)
            pallet.layer.shadowRadius = 5.23
            pallet.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            pallet.layer.shadowOpacity = 0.23
        }
        
        tileWidth = pallet.topTile.frame.width
        
        originS = CGPoint(x: self.view.center.x , y: self.view.center.y - pallet.frame.height/2 + 35)
        swipeController!.squares[0].alpha = 0.0
        
        swipeController!.originS = self.originS
        swipeController!.currentS = self.currentS
        
        NSLayoutConstraint.activate([
            slidersStackView.topAnchor.constraint(equalTo: (swipeController?.squares[0].bottomAnchor)!, constant: 80)
               ])
        
    }
    //MARK: - Gestures Handlers
    @IBAction func cameraPressed(_ sender: UIButton) {
  
//        performSegue(withIdentifier: "mainToCamera", sender: self)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
//        controller.isModalInPresentation = true
        controller.delegate = self
        
        let transition = CATransition.init()
        transition.duration = 0.45
        transition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.default)
        transition.type = CATransitionType.push //Transition you want like Push, Reveal
        transition.subtype = CATransitionSubtype.fromLeft // Direction like Left to Right, Right to Left
        transition.delegate = self
        view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @objc func stackLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began{
            btnStack.animateSizeOn()
            performSegue(withIdentifier: "mainToCollection", sender: self)
        }else if sender.state == .ended{
            btnStack.animateSizeOff()
//            displayAlert()
        }
        
    }
    
    //MARK: - Pallet SetUp
    func palletSetUp() {
        
        let newPallet = Pallet()
        
        swipeController?.squares.append(newPallet)
        
        let width = UIScreen.main.bounds.size.width * 0.614
        
        view.addSubview(newPallet)
        newPallet.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            newPallet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            newPallet.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30),
//            newPallet.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50),
//            newPallet.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -50),
            newPallet.widthAnchor.constraint(equalToConstant: width)
//            newPallet.bottomAnchor.constraint(equalTo: slidersStackView.topAnchor, constant: -20)
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
//            viewController.miniPalletsCD = self.miniPalletsCD
            
            viewController.delegate = self
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    func saveTile(){
            if editingMode == false {
                let newMiniPalletCD = MiniPalletModel(context: self.context)
                    newMiniPalletCD.topColor = tilesColors.top
                    newMiniPalletCD.secondColor = tilesColors.second
                    newMiniPalletCD.thirdColor = tilesColors.third
                    newMiniPalletCD.bottomColor = tilesColors.bottom
                    newMiniPalletCD.name = palletName
                    miniPalletsCD.append(newMiniPalletCD)
                    do {
                        try context.save()
                    } catch {
                        print("Error saving context \(error)")
                    }
            }else{
                let request:NSFetchRequest<MiniPalletModel> = MiniPalletModel.fetchRequest()
                let nameFilter = NSPredicate(format: "name MATCHES[cd] %@", self.palletName)
                request.predicate = nameFilter
                
                do {
                    let myPallet = try context.fetch(request)
                    print(myPallet.count)
                    myPallet[0].setValue(tilesColors.top, forKey: "topColor")
                    myPallet[0].setValue(tilesColors.second, forKey: "secondColor")
                    myPallet[0].setValue(tilesColors.third, forKey: "thirdColor")
                    myPallet[0].setValue(tilesColors.bottom, forKey: "bottomColor")
                    try context.save()
                }catch{
                    print("error retrieving data")
                }
            }
    }
    func loadPallets(with request: NSFetchRequest<MiniPalletModel> = MiniPalletModel.fetchRequest(), predicate: NSPredicate? = nil){
        
        
        
    }
    func prepareForDetails(with segue: UIStoryboardSegue,with sender: Any?){
        if let viewController = segue.destination as? ColorDetailControler {
            viewController.delegate = self
            if let safeTile = pallet.activeTile {
                viewController.mainColor = safeTile.contentView.backgroundColor ?? .black
                viewController.hexaCode = safeTile.hexaCode
                viewController.redCode = Int(safeTile.redCode!)
                viewController.greenCode = Int(safeTile.greenCode!)
                viewController.blueCode = Int(safeTile.blueCode!)
                
//                print("r: \(safeTile.redCode!) g: \(safeTile.greenCode!) b: \(safeTile.blueCode!)")
                
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
        
        if let localPallet = pallet.activeTile {
            if sliderCallOut != nil {
                sliderCallOut?.alpha += 0.05
            }else{
                sliderCallOut = SliderCallout()
                sliderCallOut?.frame.size = CGSize(width: 50, height: 30)
                sliderCallOut?.frame.origin.x = xCoordinate
                sliderCallOut?.frame.origin.y = yCoordinate
                sliderCallOut?.alpha = 0
                
                superView.addSubview(sliderCallOut!)
            }
            switch sender.accessibilityIdentifier {
            case "sldRed":
                red = CGFloat(sender.value)
//                print("slider value :\(red)")
                sliderCallOut?.calloutLabel.text = String(Int(sender.value * 255))
                
                sliderRed.minimumTrackTintColor = UIColor(displayP3Red: red, green: 0.5 * red, blue: 0.5 * red, alpha: 1)
                
                animateSliderCallOut(sender: sliderCallOut!, xCoordinate: xCoordinate)
                localPallet.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
                localPallet.hexaLabel.prepareColor(red: red, green: green, blue: blue)
                localPallet.hexaLabel.text = localPallet.contentView.backgroundColor?.toHexString()
                localPallet.redCode = Int(red * 255)
                btnReset.animateGradient(startColor: (pallet.activeTile?.contentView.backgroundColor)!)
                
            case "sldGreen":
                green = CGFloat(sender.value)
                sliderCallOut?.calloutLabel.text = String(Int(sender.value * 255))
                sliderGreen.minimumTrackTintColor = UIColor(displayP3Red: 0.5*green, green: green, blue: 0.5 * red, alpha: 1)
                animateSliderCallOut(sender: sliderCallOut!, xCoordinate: xCoordinate)
                localPallet.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
                localPallet.hexaLabel.prepareColor(red: red, green: green, blue: blue)
                localPallet.hexaLabel.text = pallet.activeTile?.contentView.backgroundColor?.toHexString()
                localPallet.greenCode = Int(green * 255)
                btnReset.animateGradient(startColor: (localPallet.contentView.backgroundColor)!)
                
            case "sldBlue":
                self.blue = CGFloat(sender.value)
                sliderCallOut?.calloutLabel.text = String(Int(sender.value * 255))
                sliderBlue.minimumTrackTintColor = UIColor(displayP3Red: blue * 0.5, green: 0.5 * blue, blue: blue, alpha: 1)
                animateSliderCallOut(sender: sliderCallOut!, xCoordinate: xCoordinate)
                localPallet.contentView.backgroundColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
                localPallet.hexaLabel.prepareColor(red: red, green: green, blue: blue)
                localPallet.hexaLabel.text = pallet.activeTile?.contentView.backgroundColor?.toHexString()
                localPallet.blueCode = Int(blue * 255)
                btnReset.animateGradient(startColor: (localPallet.contentView.backgroundColor)!)
            default:
                print("error")
            }
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
    func animateSlidersMinTint(slider: UISlider, color: UIColor){
        
//        let tintAnimation = CABasicAnimation(keyPath: "minTrackTintColor")
//        tintAnimation.duration = 1
//        tintAnimation.toValue = color.cgColor
//        tintAnimation.autoreverses = false
////        tintAnimation.timingFunction =
//        slider.layer.add(tintAnimation, forKey: nil)
        
    }
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
//            case .began:
//                animateSlidersMinTint(slider: sliderRed, color: .systemRed)
            case .ended:
                UIView.animate(withDuration: 0.66 ,delay: 0.0, animations: {
                    self.sliderCallOut?.alpha = 0
                }) { (finished: Bool) in
                    self.sliderCallOut?.removeFromSuperview()
                    self.sliderCallOut = nil
                }
                slider.minimumTrackTintColor = .systemGray
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
        
        red = (tile.contentView.backgroundColor?.rgb.red)!
        green = (tile.contentView.backgroundColor?.rgb.green)!
        blue = (tile.contentView.backgroundColor?.rgb.blue)!
        
        tile.hexaLabel.text = tile.contentView.backgroundColor?.toHexString()
        
        UIView.animate(withDuration: 0.63, delay: 0,options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.sliderRed.setValue(Float(self.red), animated: true)
            self.sliderGreen.setValue(Float(self.green), animated: true)
            self.sliderBlue.setValue(Float(self.blue), animated: true)
        }, completion: nil)
    }
    //MARK: - Delegate Methods
    func viewDidDisapear(topColor: String, secondColor: String, thirdColor: String, bottomColor: String, editingMode: Bool, palletName: String) {
        pallet.topTile.contentView.backgroundColor = UIColor(hexString: topColor)
        pallet.secondTile .contentView.backgroundColor = UIColor(hexString: secondColor)
        pallet.thirdTile.contentView.backgroundColor = UIColor(hexString: thirdColor)
        pallet.bottomTile.contentView.backgroundColor = UIColor(hexString: bottomColor)
        
        self.editingMode = editingMode
        
        self.palletName = palletName
        
    }
    func collectionViewDidDisapearWithNoSelection(editingMode: Bool){
        self.editingMode = editingMode
    }
    func panDidEnd(topColor: String, secondColor: String, thirdColor: String, bottomColor: String) {
        tilesColors.top = topColor
        tilesColors.second = secondColor
        tilesColors.third = thirdColor
        tilesColors.bottom = bottomColor
        if editingMode {
            saveTile()
        }else{
            displayAlert()
        }
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
            safeTile.redCode = Int((safeTile.contentView.backgroundColor?.rgb.red)! * 255)
//            print("check redCode set : \(safeTile.contentView.backgroundColor?.rgb.red))")
            safeTile.greenCode = Int((safeTile.contentView.backgroundColor?.rgb.green)! * 255)
            safeTile.blueCode = Int((safeTile.contentView.backgroundColor?.rgb.blue)! * 255)
            //
        }
        performSegue(withIdentifier: "mainToColorDetail", sender: Any?.self)
    }
    func displayAlert() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Name your pallet", message: "", preferredStyle: .alert)
        action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField.text {
                if name == "" {
//                    self.dismiss(animated: false, completion: nil)
                }else{
                    action.isEnabled = true
                    self.palletName = name
                    self.saveTile()
                    print(name)
                }
            }
        }
        alert.addAction(action!)
        action!.isEnabled = false
        alert.addTextField { (field) in
            textField = field
            field.delegate = self
            textField.placeholder = "Your pallet's name"
        }
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - General functions
public func addParallaxToView(vw: UIView) {
    let amount = 8
    
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
extension ViewController: PhotoViewControllerDelegte {
    func getColor(color: UIColor) {
        pallet.topTile.contentView.backgroundColor = color
    }
}
extension ViewController: ColorDetailControlerDelegate{
    func colorDetailDelegateDidDisapear() {
        pallet.activeTile?.transformOff()
        pallet.activeTile?.tileIsActive = false
        pallet.activeTile = nil
    }
}
extension ViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        action?.isEnabled = (newText.count > 0)
        
        return true
    }
}

extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0{
            didSet{
                if r > 1 {
                    r = 1
                }else if r < 0{
                    r = 0
                }
            }
        }
        var g:CGFloat = 0{
            didSet{
                if g > 1 {
                    g = 1
                }else if g < 0{
                    g = 0
                }
            }
        }
        var b:CGFloat = 0{
            didSet{
                if b > 1 {
                    b = 1
                }else if b < 0{
                    b = 0
                }
            }
        }
        var a:CGFloat = 0{
            didSet{
                if a > 1 {
                    a = 1
                }else if a < 0{
                    a = 0
                }
            }
        }
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06X", rgb) as String
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}



