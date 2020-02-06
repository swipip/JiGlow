import UIKit
import CoreData

class ViewController: UIViewController{
    
    //MARK: - Outlets
    
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
    @IBOutlet weak var btnReset: GradientButton!
    @IBOutlet var superView: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnStack: GradientButton!
    
    //MARK: - Variables
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // variable the model looks to choose between C || U
    var editingMode = false
    
    var red: CGFloat = 0.5
    var green: CGFloat = 0.5
    var blue: CGFloat = 0.5
    
    var descriptionLabel: ColorLabel?
    var sliderCallOut: UIView?
    private var sliderCallOutLabel: UILabel?
    var pallet = Pallet()
    var tileWidth: CGFloat = 0.0
    private var tilesColors: (top: String?, second: String?, third: String?, bottom: String?)
    var palletName: String = ""
    var action: UIAlertAction?
    
    var longPressGestureStack: UILongPressGestureRecognizer?
    var longPressGestureReset: UILongPressGestureRecognizer?
    
    private var miniPalletsCD = [MiniPalletModel]()
    
    var swipeController: SwipeController?
    var originS: CGPoint?
    var currentS = CGPoint()
    
    private var callOutleadingConstraint: NSLayoutConstraint?
    
    private var gradientConfirmations = [String:RadialGradientView]()
    //MARK: - Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let path = FileManager
        //        .default
        //        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        //        .last?
        //        .absoluteString
        //        .replacingOccurrences(of: "file://", with: "")
        //        .removingPercentEncoding
        //        print(path!)
        
        swipeController = SwipeController(view: self.view)
        swipeController?.delegate = self
        
        
        btnCamera.layer.cornerRadius = 25
        btnStack.layer.cornerRadius = 25
        
        addParallaxToView(vw: btnReset)
        
        sliderRed.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderGreen.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        sliderBlue.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        palletSetUp()
        palletSetUp()
        swipeController?.squares[0].secondTile.contentView.backgroundColor = .red
        
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        palletLayout()
        btnReset.setButton()
        addConfirmationViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.isHidden = false
        
    }

    //MARK: - Data Management
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
    //MARK: - Gestures Handlers
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                
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
    @objc func stackLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began{
            btnStack.animateSizeOn()
            performSegue(withIdentifier: "mainToCollection", sender: self)
        }else if sender.state == .ended{
            btnStack.animateSizeOff()

        }
        
    }
    @objc func panHandler(recognizer: UIPanGestureRecognizer){
        swipeController?.handlePan(recognizer: recognizer)
        
        if recognizer.state == .ended {
            animateConfirmationOut()
        }
    }
    //MARK: - Pallet SetUp
    typealias CompletionHandler = (_ success:Bool) -> Void
    func palletSetUp(completionHandler: CompletionHandler? = nil) {
        
        let newPallet = Pallet()

        swipeController?.squares.append(newPallet)
        
        let width = CGFloat(pallet.compoundedHeight * 0.88)
        
        view.addSubview(newPallet)
        newPallet.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            newPallet.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            newPallet.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30),
            newPallet.widthAnchor.constraint(equalToConstant: width)
        ])
        
        let palletPan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(recognizer:)))
        palletPan.delegate = self
        
        newPallet.addGestureRecognizer(palletPan)
        
        completionHandler?(true)
        
    }
    private func palletLayout(completionHandler: CompletionHandler? = nil){
        pallet = (swipeController?.squares[1])!
        pallet.delegate = self
        for pallet in swipeController!.squares{
            pallet.topTile.roundCorners([.topRight, .topLeft], radius: 18)
            pallet.bottomTile.roundCorners([.bottomRight, .bottomLeft], radius: 18)
            pallet.layer.shadowRadius = 5.23
            pallet.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            pallet.layer.shadowOpacity = 0.23
        }
        
        tileWidth = pallet.topTile.frame.width
        
        originS = CGPoint(x: self.view.center.x , y: pallet.center.y)
        swipeController!.squares[0].alpha = 0.0
        
        swipeController!.currentS = self.currentS

        completionHandler?(true)
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
    func prepareForDetails(with segue: UIStoryboardSegue,with sender: Any?){
        if let viewController = segue.destination as? ColorDetailControler {
            viewController.delegate = self
            if let safeTile = pallet.activeTile {
                viewController.mainColor = safeTile.contentView.backgroundColor ?? .black
                viewController.hexaCode = safeTile.hexaCode
                viewController.redCode = Int(safeTile.redCode!)
                viewController.greenCode = Int(safeTile.greenCode!)
                viewController.blueCode = Int(safeTile.blueCode!)
                
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
    @IBAction func sliderSlide(_ sender: UISlider) {
        
        let sliderCoordinates = self.view.convert(sender.frame, from:sliderRed)
        let xCoordinate = sender.thumbCenterX + (self.view.frame.size.width - sliderRed.frame.size.width)/4 - 2.5
        let yCoordinate = sliderCoordinates.origin.y - CGFloat(30)
        
        addSliderCallOut(slider: sender)
        
        if let tile = pallet.activeTile {
            manageSlideUponSliderSlide(tile: tile, sender: sender, coordinates: CGPoint(x: xCoordinate, y: yCoordinate))
            
        }else if let tile = pallet.topTile{
            tile.transformOn()
            tile.animateLabelAlphaOn()
            manageSlideUponSliderSlide(tile: tile, sender: sender, coordinates: CGPoint(x: xCoordinate, y: yCoordinate))
        }
        
    }
    func manageTileUponSliderSlide(tile: Tile,slider: UISlider){
        
        let color = UIColor(red: Int(red*255), green: Int(green*255), blue: Int(blue*255))
        
        animateSliderCallOut(slider: slider)
        sliderCallOutLabel?.text = String(Int(slider.value * 255))
        tile.contentView.backgroundColor = color
        tile.hexaLabel.adjustTextColor(red: red, green: green, blue: blue)
        tile.hexaLabel.text = color.toHexString()
        btnReset.animateGradient(startColor: (tile.contentView.backgroundColor)!)
    }
    func manageSlideUponSliderSlide(tile: Tile,sender: UISlider,coordinates: CGPoint){
        switch sender.accessibilityIdentifier {
        case "sldRed":
            red = CGFloat(sender.value)
            
            sliderRed.minimumTrackTintColor = UIColor(displayP3Red: red, green: 0.5 * red, blue: 0.5 * red, alpha: 1)
            tile.redCode = Int(red * 255)
            
            manageTileUponSliderSlide(tile: tile, slider: sender)
            
        case "sldGreen":
            green = CGFloat(sender.value)
            
            sliderGreen.minimumTrackTintColor = UIColor(displayP3Red: 0.5*green, green: green, blue: 0.5 * red, alpha: 1)
            tile.greenCode = Int(green * 255)
            
            manageTileUponSliderSlide(tile: tile, slider: sender)
            
        case "sldBlue":
            self.blue = CGFloat(sender.value)
            
            sliderBlue.minimumTrackTintColor = UIColor(displayP3Red: blue * 0.5, green: 0.5 * blue, blue: blue, alpha: 1)
            tile.blueCode = Int(blue * 255)
            
            manageTileUponSliderSlide(tile: tile, slider: sender)
            
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
    //MARK: - Add Subviews
    func addConfirmationViews() {
        
        gradientConfirmations["green"] = confirmationViewSetUp(position: .right)
        gradientConfirmations["red"] = confirmationViewSetUp(position: .left)
        
    }
    func confirmationViewSetUp(position: GradientConfirmationScreenPosition) -> RadialGradientView{
        let newConfirmationGradient = RadialGradientView()

        let color:UIColor = position == .right ? UIColor.systemGreen : UIColor.systemRed
        newConfirmationGradient.right = position == .right ? true : false
        
        newConfirmationGradient.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        newConfirmationGradient.frame.origin = CGPoint(x: 0, y: -pallet.center.y)
        
        newConfirmationGradient.insideColor = color
        newConfirmationGradient.outSideColor = .white
        newConfirmationGradient.radius = 300
        newConfirmationGradient.alpha = 0.0
        newConfirmationGradient.backgroundColor = .clear
        
        self.view.insertSubview(newConfirmationGradient, at: 0)
        
        return newConfirmationGradient
    }
    func addSliderCallOut(slider: UISlider) {
        
        if sliderCallOut == nil {
            sliderCallOut = UIView()
            if let callOut = sliderCallOut {
                callOut.backgroundColor = .gray
                callOut.layer.cornerRadius = 15
                callOut.frame.origin.x = slider.thumbCenterX - callOut.frame.size.width/2
                callOut.frame.origin.y = slider.frame.origin.y - 35
                callOut.frame.size = CGSize(width: 30, height: 30)
                self.view.addSubview(callOut)
                
                sliderCallOutLabel = UILabel()
                
                if let label = sliderCallOutLabel {
                    label.text = "123"
                    label.font = UIFont(name: "Galvji", size: 10)
                    label.textColor = .white
                    label.textAlignment = .center
                    label.frame.origin.x = slider.thumbCenterX - label.frame.size.width/2
                    label.frame.origin.y = slider.frame.origin.y - 35
                    label.frame.size = CGSize(width: 30, height: 30)
                    view.addSubview(label)
                    
                }
            }
        }else{
            sliderCallOut?.alpha += 0.05
        }
    }
    //MARK: - Animations
    func animateConfirmationOut() {
        UIView.animate(withDuration: 0.6) {
            self.gradientConfirmations["green"]?.alpha = 0.0
            self.gradientConfirmations["red"]?.alpha = 0.0
        }
    }

    func animateSliderCallOut(slider: UISlider) {
        UIView.animate(withDuration: 0.5, animations: {
            self.sliderCallOut?.frame.origin.x = slider.thumbCenterX - (self.sliderCallOut?.frame.width)!/2
            self.sliderCallOutLabel?.frame.origin.x = slider.thumbCenterX - (self.sliderCallOutLabel?.frame.width)!/2
//            self.view.layoutIfNeeded()
            
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
    //MARK: - Pop-up Alerts
    func displayAlert() {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Name your pallet", message: "", preferredStyle: .alert)
        
        let dismiss = UIAlertAction(title: "Cancel", style: .default) { (action) in
            print("dissmissed")
        }
        alert.addAction(dismiss)

        action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = textField.text {

                action.isEnabled = true
                self.palletName = name
                self.saveTile()
                print(name)
                
            }
        }
        alert.addAction(action!)
        
        alert.view.tintColor = .label
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
//MARK: - VC Extensions
extension ViewController: PhotoViewControllerDelegte {
    func getColor(color: UIColor) {
        pallet.topTile.contentView.backgroundColor = color
        
        if color.getWhiteAndAlpha.white < 0.5 {
            pallet.secondTile.contentView.backgroundColor = color.darken(by: 10)
            pallet.thirdTile.contentView.backgroundColor = color.darken(by: 20)
            pallet.bottomTile.contentView.backgroundColor = color.darken(by: 30)
        }else{
            pallet.secondTile.contentView.backgroundColor = color.lighten(by: 10)
            pallet.thirdTile.contentView.backgroundColor = color.lighten(by: 20)
            pallet.bottomTile.contentView.backgroundColor = color.lighten(by: 30)
        }
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
extension ViewController: PalletDelegate {
    func tileTapped() {
        if pallet.activeTile != nil{
            animateSliders(tile: pallet.activeTile!)
            if let color = pallet.activeTile?.contentView.backgroundColor {
                self.btnReset.animateGradient(startColor: color)
            }
        }
    }
    func tileLongTapped() {
        //Vibrate
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
        
        if let safeTile = pallet.activeTile {
            safeTile.hexaCode = safeTile.contentView.backgroundColor?.toHexString()
            safeTile.redCode = Int((safeTile.contentView.backgroundColor?.rgb.red)! * 255)
            safeTile.greenCode = Int((safeTile.contentView.backgroundColor?.rgb.green)! * 255)
            safeTile.blueCode = Int((safeTile.contentView.backgroundColor?.rgb.blue)! * 255)
        }
        performSegue(withIdentifier: "mainToColorDetail", sender: Any?.self)
    }
}
extension ViewController: SwipeControllerDelegate{
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
        palletLayout()
        
    }
    func didUpdatePalletPosition(position: CGFloat, direction: Direction) {
        if direction == .right {
            gradientConfirmations["green"]?.alpha = position
        }else{
            gradientConfirmations["red"]?.alpha = position
        }
    }
}
extension ViewController: CollectionControllerDelegate{
    
    func collectionViewDidDisapearWithNoSelection(editingMode: Bool){
        self.editingMode = editingMode
    }
    
    func collectionControllerDidDisapear(topColor: String, secondColor: String, thirdColor: String, bottomColor: String, editingMode: Bool, palletName: String) {
        pallet.topTile.contentView.backgroundColor = UIColor(hexString: topColor)
        pallet.secondTile .contentView.backgroundColor = UIColor(hexString: secondColor)
        pallet.thirdTile.contentView.backgroundColor = UIColor(hexString: thirdColor)
        pallet.bottomTile.contentView.backgroundColor = UIColor(hexString: bottomColor)
        
        self.editingMode = editingMode
        
        self.palletName = palletName
        
    }
}
extension ViewController: CAAnimationDelegate{
    
}
extension UISlider {
    var thumbCenterX: CGFloat {
        return thumbRect(forBounds: frame, trackRect: trackRect(forBounds: frame), value: value).midX
    }
}
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        swipeController?.originS = CGPoint(x: pallet.center.x, y: pallet.center.y)
        return true
    }
}
enum GradientConfirmationScreenPosition{
    case right,left
}
