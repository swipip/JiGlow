import UIKit
import CoreData

let sliderBeganNotificationKey = "co.billardgautier.sliderBegan"

class ViewController: UIViewController {
    
    //MARK: - UI Elements
    private var resetButton: GradientButton!
    private var resetButtonBackView: UIView!
    private var palettes = [Palette]()
    private var swipeValidationIndicator = [UIView]()
    private var navBar: CustomNavBar!
    private var titleBar: TitleBar!
    private var sliders = [CustomSlider]()
    private var sliderCallOut: UIView?
    private var sliderCallOutLabel: UILabel?
    private var returnButton: UIButton!
    //MARK: - Layout Elements
    private var margins: CGFloat = 80
    private var validationButtonsCenterConstraint = [NSLayoutConstraint]()
    private var paletteOriginPoint: CGPoint?
    private var animator: UIViewPropertyAnimator!
    private var screenAdjustment: CGFloat = 0.0
    //MARK: - Data Elements
    private var editingMode = false
    private var paletteName = ""
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //MARK: - Variables
    //Colors
    private var red:CGFloat = 0,green :CGFloat = 0, blue:CGFloat = 0
    private var colorSave = [UIColor]()
    private var colors = [String]()
    //Time Tracking
    private var sliderTimer = Timer()
    private var startTime:CFTimeInterval = CFAbsoluteTimeGetCurrent()
    //Bools
    private var notificationHappened = false
    private var returnIsPresenting = false
    private var angleFactor: CGFloat? {
        willSet {
            if abs(newValue!) >= 1 {
                notificationHappened = true
            }else{
                notificationHappened = false
            }
        }
    }
    //Others
    private var returnTapCount = 0.0
    private let sliderBegan = Notification.Name(sliderBeganNotificationKey)
    private var k = K()
    private var action: UIAlertAction!
    //MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
         k.isFrench()
        
        navigationController?.navigationBar.isHidden = true
        
        screenAdjustment = k.checkScreenSize(view: self.view) < 2 ? 10.0 : 0.0
        
        margins += screenAdjustment*1.7
        
        navBar = CustomNavBar(frame: CGRect(x: -1, y: self.view.frame.height,width:  self.view.frame.width + 2, height:  90),
                              buttonTitles: ["Photo","Stack"],
                              images: [UIImage(systemName: "camera.fill")!,UIImage(systemName: "rectangle.stack.fill")!])
        
        self.view.addSubview(navBar)
        navBar.delegate = self
        
        titleBar = TitleBar(frame: CGRect(x: 0, y: 0 - screenAdjustment, width: self.view.frame.size.width, height: 90))
        self.view.addSubview(titleBar)
        
        
        addPalettes(qty: 2)
        updateColor()
        
        addSliders()
        paletteOriginPoint = palettes.last?.center
        palettes[0].alpha = 0.0
        addObservers()
        
        launchScreenAnimation()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sliderTimer.invalidate()
        self.returnIsPresenting = false
        self.returnButton!.isEnabled = false
        self.animateInteractionButtons(on: false)
        swipeValidationIndicator.forEach({$0.removeFromSuperview()})
        swipeValidationIndicator.removeAll()
        validationButtonsCenterConstraint.removeAll()
        
    }
    override func viewDidLayoutSubviews() {
        navigationController?.navigationBar.isHidden = true
    }
    fileprivate func updateColor() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.palettes.last?.updateColors(color: .systemPurple)
        }else{
            self.palettes.last?.updateColors(color: .systemOrange)
        }
    }

    //MARK: - Launch Animation
    fileprivate func loadAnimation() {
        self.addResetButton()
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { (timer) in
            self.addReturnButton()
            self.addValidationButtons()
            self.resetButton.setButton()
            timer.invalidate()
        }
        
        self.addAnimator(on: false)
        self.animator.startAnimation()
        
        
        UIView.animate(withDuration: 0.4, animations: {
            self.navBar.frame.origin.y -= 89
            self.resetButton.alpha = 1
        }, completion: {(ended) in
            var resetBtnColor = UIColor.systemOrange
            if self.traitCollection.userInterfaceStyle == .dark {resetBtnColor = .systemPurple}
            self.resetButton.animateGradient(startColor: resetBtnColor)
        })
    }
    
    func launchScreenAnimation() {
        
        navigationController?.navigationBar.alpha = 0.0
        
        let image = UIImageView(image: UIImage(named: "LaunchScreenNT"))
        
        self.view.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([image.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                                     image.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                                     image.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                                     image.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)])
        
        let logo = UIImageView(image: UIImage(named: "JiglowLogo"))
        logo.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        self.view.addSubview(logo)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([logo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
                                     logo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)])
        
        UIView.animate(withDuration: 1, delay: 1 ,animations: {
            self.navigationController?.navigationBar.alpha = 1.0
            image.alpha = 0.0
            logo.transform = CGAffineTransform(scaleX: 100, y: 100)
            logo.alpha = 0.0
        }, completion: {(finished) in
            if finished {
                image.removeFromSuperview()
                logo.removeFromSuperview()
                self.loadAnimation()
            }
        })
        
        
    }
    //MARK: - Data Handling
    func saveTile(){
        if editingMode == false {
            let newMiniPalletCD = MiniPalletModel(context: self.context)
            newMiniPalletCD.topColor = colors[0]
            newMiniPalletCD.secondColor = colors[2]
            newMiniPalletCD.thirdColor = colors[1]
            newMiniPalletCD.bottomColor = colors[3]
            newMiniPalletCD.name = paletteName
            do {
                try context.save()
                colors.removeAll()
            } catch {
                print("Error saving context \(error)")
            }
        }else{
            let request:NSFetchRequest<MiniPalletModel> = MiniPalletModel.fetchRequest()
            let nameFilter = NSPredicate(format: "name MATCHES[cd] %@", self.paletteName)
            request.predicate = nameFilter

            print(paletteName)
            
            do {
                let myPallet = try context.fetch(request)
                print(myPallet.count)
                let colors = self.colors
                for (i,_) in colors.enumerated() {
                    let color = UIColor(hexString: colors[i])
                    print(color)
                }
                myPallet[0].setValue(colors[0], forKey: "topColor")
                myPallet[0].setValue(colors[2], forKey: "secondColor")
                myPallet[0].setValue(colors[1], forKey: "thirdColor")
                myPallet[0].setValue(colors[3], forKey: "bottomColor")
                try context.save()
                self.colors.removeAll()
            }catch{
                print("error retrieving data")
            }
        }
    }
    //MARK: - Pop-up Alerts
    func displayAlert() {
        
        var textField = UITextField()
        let alert = UIAlertController(title: k.nameYourPallet, message: "", preferredStyle: .alert)
        
//        print(colors.count)
        
        let dismiss = UIAlertAction(title: k.cancel, style: .default) { (action) in
            
            self.palettes.last!.updateColors(color: .red, colors: self.colors)
            self.colors.removeAll()
            
            self.startTime = CFAbsoluteTimeGetCurrent()
            
        }
        alert.addAction(dismiss)
        
        action = UIAlertAction(title: k.add, style: .default) { (action) in
            if let name = textField.text {

                action.isEnabled = true
                self.paletteName = name
                self.saveTile()
                self.updateColor()
                self.startTime = CFAbsoluteTimeGetCurrent()

            }
        }
        alert.addAction(action!)

        alert.view.tintColor = .label
        action!.isEnabled = false
        alert.addTextField { (field) in
            textField = field
            field.delegate = self
            textField.placeholder = self.k.renamePalletPlaceHolder
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Observers
    func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSliderTimer(notification:)), name: sliderBegan, object: nil)
        
    }
    //MARK: - Timers
    @objc func updateSliderTimer(notification: NSNotification) {
        
        let start = notification.userInfo?["start"] as! Double
        
        sliderTimer.invalidate()
        
        sliderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - start
            
            if timeElapsed > 5 {
                self.returnIsPresenting = false
                self.returnButton!.isEnabled = false
                self.animateInteractionButtons(on: false)
                timer.invalidate()
                self.sliderTimer.invalidate()
            }
        }
        
    }
    //MARK: - Reset Button
    func addResetButton() {
        
        let height:CGFloat = 50.0
        
        resetButtonBackView = UIView()
        resetButtonBackView.backgroundColor = UIColor(named: "mainBackground")
        resetButtonBackView.layer.cornerRadius = (height + 10)/2
        
        self.view.addSubview(resetButtonBackView)
        
        resetButtonBackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([resetButtonBackView.centerYAnchor.constraint(equalTo: navBar.topAnchor, constant: 0),
                                     resetButtonBackView.centerXAnchor.constraint(equalTo: navBar.centerXAnchor, constant: 0),
                                     resetButtonBackView.widthAnchor.constraint(equalToConstant: 130),
                                     resetButtonBackView.heightAnchor.constraint(equalToConstant: height+10)])
      
        resetButton = GradientButton()
        resetButton.layer.cornerRadius = height/2
        resetButton.backgroundColor = .systemOrange
        resetButton.setTitle(k.resetButtonTitle, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        resetButton.alpha = 0.0
        
        self.view.addSubview(resetButton)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([resetButton.centerYAnchor.constraint(equalTo: navBar.topAnchor, constant: 0),
                                     resetButton.centerXAnchor.constraint(equalTo: navBar.centerXAnchor, constant: 0),
                                     resetButton.widthAnchor.constraint(equalToConstant: 120),
                                     resetButton.heightAnchor.constraint(equalToConstant: height)])
        
        resetButton.addTarget(self, action: #selector(resetPressed(_sender:)), for: .touchUpInside)
        
        resetButton.animateAlphaOn()
        resetButtonBackView.animateAlpha(on: true, withDuration: 0.3)
    }

    
    @IBAction func resetPressed(_sender: UIButton) {
        
        palettes.last?.animateTile(on: false)
        updateColor()
        colors.removeAll()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.palettes.last?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.palettes.last?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_) in
                self.palettes.last?.activeTile?.layer.removeAllAnimations()
            })
            }
    }
    //MARK: - Sliders
    func addSliders() {

        var botAnchor:CGFloat = 130 - screenAdjustment
        let spread:CGFloat = max(self.view.frame.size.height * 0.09,30)
        
        let red = UIColor(red: 255, green: 118, blue: 129)
        let green = UIColor(red: 0, green: 137, blue: 126)
        let blue = UIColor(red: 73, green: 120, blue: 208)
        
        let colors = [blue,green,red]
        
        for i in 0...2 {
            
            let newSlider = CustomSlider()
            newSlider.value = 0.5
            newSlider.minimumTrackTintColor = colors[i]
            self.view.addSubview(newSlider)
            
            newSlider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                         newSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: margins),
                                         newSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -margins),
                                         newSlider.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -botAnchor)])
            
            botAnchor += spread
            
            newSlider.addTarget(self, action: #selector(sliderSlides(_:event:)), for: .valueChanged)
            
            self.sliders.append(newSlider)
            
        }
    }
    @IBAction func sliderSlides(_ sender: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            
            var tile: Tile
            
            if palettes.last?.activeTile == nil {
                //If slider slides with no active tile select the second one starting from top
                tile = (palettes.last?.tiles[1])!
                self.animateSliders(forTile: tile)
            }else{
                //other wise local tile is set to active tile
                tile = palettes.last!.activeTile!
            }
            
            switch touchEvent.phase {
            case .began:
                
                let notification = Notification.Name(rawValue: sliderBeganNotificationKey)
                let sliderStartTime = CFAbsoluteTimeGetCurrent()
                NotificationCenter.default.post(name: notification, object: nil, userInfo: ["start":sliderStartTime])
                
                //Reveal return button
                animateInteractionButtons(on: true)
                // Save colors for return button
                colorSave.insert(tile.back.backgroundColor!, at: 0)
                // Slider call out with slider's value
                addSliderCallOut(slider: sender)
                updateRGB(tile: tile)
                sliderCallOutLabel?.text = String(Int(sender.value * 255))
                
                if palettes.last?.activeTile == nil {
                    palettes.last?.animateTile(on: true)
                    
                }
            case .ended:
                
                UIView.animate(withDuration: 0.2 ,delay: 0.0, animations: {
                    self.sliderCallOut?.alpha = 0
                    self.sliderCallOutLabel?.alpha = 0
                }) { (finished: Bool) in
                    self.sliderCallOutLabel?.removeFromSuperview()
                    self.sliderCallOut?.removeFromSuperview()
                    self.sliderCallOut = nil
                }
                
            default:
                sliderCallOutLabel?.text = String(Int(sender.value * 255))
                animateSliderCallOut(slider: sender)
                switch sender {
                case sliders[2]:
                    red = CGFloat(sender.value)
                    updateTileColorUponSliderSlide(tile: tile)
                case sliders[1]:
                    green = CGFloat(sender.value)
                    updateTileColorUponSliderSlide(tile: tile)
                case sliders[0]:
                    blue = CGFloat(sender.value)
                    updateTileColorUponSliderSlide(tile: tile)
                default:
                    break
                }
            }
        }
        
    }
    func updateTileColorUponSliderSlide(tile: Tile) {
        let color = UIColor(red: Int(red*255), green: Int(green*255), blue: Int(blue*255))
        
        tile.back.backgroundColor = color
        tile.label.adjustTextColor(color: color)
        tile.label.text = color.toHexString()
        tile.infoButton.adjustTextColor(color: color)
        
        resetButton.animateGradient(startColor: color, endColor: color.withHueOffset(offset: 1/16))
    }
    func animateSliders(forTile tile: Tile) {
        //Positions sliders thumbs on selected tile's RGB values
        updateRGB(tile: tile)
        
        tile.label.text = tile.back.backgroundColor?.toHexString()
        
        let values = [blue,green,red]
        
        for (i,slider) in sliders.enumerated() {
            UIView.animate(withDuration: 0.63, delay: 0,options: UIView.AnimationOptions.curveEaseOut, animations: {
                slider.setValue(Float(values[i]), animated: true)
            }, completion: nil)
        }
    }
    func updateRGB(tile: Tile) {
        
        let color = tile.back.backgroundColor
        
        red = (color?.rgb.red)!
        green = (color?.rgb.green)!
        blue = (color?.rgb.blue)!
        
    }
    //MARK: - Slider CallOuts
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
    func animateSliderCallOut(slider: UISlider) {
        //move call out along with thumb
        UIView.animate(withDuration: 0.5, animations: {
            self.sliderCallOut?.frame.origin.x = slider.thumbCenterX - (self.sliderCallOut?.frame.width)!/2
            self.sliderCallOutLabel?.frame.origin.x = slider.thumbCenterX - (self.sliderCallOutLabel?.frame.width)!/2
        }, completion: nil)
    }
    //MARK: - Palette
    func addPalettes(qty: Int) {
        
        let height:CGFloat = self.view.frame.height * 0.083
        let x:CGFloat = margins - 10
        let y:CGFloat = 120 - screenAdjustment * 1.2
        let width:CGFloat = self.view.frame.size.width - (margins - 5) * 2
        for _ in 0...qty-1 {
            
            let newPalette = Palette(frame: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height * 4)))

            self.view.addSubview(newPalette)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(recognizer:)))
            newPalette.addGestureRecognizer(panGesture)
            newPalette.delegate = self
            
            palettes.append(newPalette)
        }
    }
    //MARK: - Swipe Handler
    @objc func panHandler(recognizer: UIPanGestureRecognizer) {
        
        guard let palette = palettes.last else {
            print("no view to animate")
            return
        }
        let translation = recognizer.translation(in: self.view)
        let newCoordinates = (x: palette.center.x + translation.x, y:palette.center.y + translation.y * 0.05 )
        
        //distance from origin
        
        let distance = self.view.center.x - newCoordinates.x
        angleFactor = -min(distance/100,1)
        
        switch recognizer.state {
        case .began:
            palettes.first?.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        case .ended:
            
            for tile in self.palettes.last!.tiles {
                self.colors.append((tile.back.backgroundColor?.toHexString())!)
            }
            
            let inOut = abs(angleFactor!) >= 1 ? true : false
            
            animateCardOut(palette, out: inOut)
            
        default:
            
            let scale = 0.85 + 0.15 * (min(abs(angleFactor!),1))
            
            palettes.first?.transform = CGAffineTransform(scaleX: scale, y: scale)
            palettes.first?.alpha = abs(angleFactor!) * 1.2
            
            palette.transform = CGAffineTransform(rotationAngle: angleFactor! * CGFloat(Double.pi / 32))
            recognizer.setTranslation(.zero, in: self.view)
            palette.center = CGPoint(x: newCoordinates.x, y: newCoordinates.y)
        }
    }
    fileprivate func handleReload(_ out: Bool, _ xDirection: Int) {
        if out {
            //Reload cards
            palettes.removeLast()
            addPalettes(qty: 1)
            if xDirection == 1 {
                //swiped right
                if editingMode {
                    saveTile()
                }else{
                    displayAlert()
                }
            }else{
                //swiped left
                colors.removeAll()
                updateColor()
                editingMode = false
            }
        }
    }
    
    func animateCardOut(_ palette: Palette, out: Bool) {
        
        let xDirection = angleFactor! < 0.0 ? -1 : 1 //Check whether user swipe left or right
        
        palettes.first?.animateAlpha(on: false, withDuration: 0.5)
        
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.12, options: .curveEaseInOut, animations: {
            palette.center = out == true ? CGPoint(x: CGFloat(xDirection) * 700, y: self.paletteOriginPoint!.y - 100) : self.paletteOriginPoint!
            palette.transform = CGAffineTransform(rotationAngle: 0 * CGFloat(Double.pi / 32))
            self.palettes.first?.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: {(ended) in
            
        })
        self.handleReload(out, xDirection)
        
    }
    func notification(){
        let feedBack = UINotificationFeedbackGenerator()
        feedBack.prepare()
        if notificationHappened == false{
            feedBack.notificationOccurred(.success)
            notificationHappened.toggle()
        }
    }
    //MARK: - Validation Buttons
    func addValidationButtons(){

        swipeValidationIndicator.forEach({$0.removeFromSuperview()})
        swipeValidationIndicator.removeAll()
        validationButtonsCenterConstraint.removeAll()
        
        let height:CGFloat = 40
        
        guard let palette = palettes.last else {
            print("no palette")
            return
        }
        
        guard let slider = sliders.last else {
            print("no sliders")
            return
        }
        
        let sliderPosition = slider.frame.origin.y
        let palettePosition = palette.frame.origin.y + palette.frame.size.height

        let distanceFromPallet = (sliderPosition - palettePosition)/2

        let marks = [UIImage(systemName: "xmark"),UIImage(systemName: "checkmark")]
        let colors = [UIColor.systemRed,UIColor.systemGreen]
//        let xPosition:[CGFloat] = [30,self.view.frame.size.width - margins*2 - height-30]
        let xPosition:[CGFloat] = [-40,+40]
        for i in 0...1 {

            let newSwipeValidationIndicator = UIButton()

            newSwipeValidationIndicator.backgroundColor = colors[i]
            newSwipeValidationIndicator.layer.cornerRadius = height/2
            newSwipeValidationIndicator.setImage(marks[i], for: .normal)
            newSwipeValidationIndicator.tintColor = .white
            newSwipeValidationIndicator.layer.shadowOffset = CGSize(width: 0, height: 0)
            if traitCollection.userInterfaceStyle == .dark {
                newSwipeValidationIndicator.layer.shadowRadius = 6
                newSwipeValidationIndicator.layer.shadowColor = colors[i].cgColor
                newSwipeValidationIndicator.layer.shadowOpacity = 0.8
            }

            self.view.addSubview(newSwipeValidationIndicator)

            newSwipeValidationIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newSwipeValidationIndicator.centerYAnchor.constraint(equalTo: slider.centerYAnchor, constant: -distanceFromPallet),
                                         newSwipeValidationIndicator.widthAnchor.constraint(equalToConstant: height),
                                         newSwipeValidationIndicator.heightAnchor.constraint(equalToConstant: height)])

            let centerYConsraint = NSLayoutConstraint(item: newSwipeValidationIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: xPosition[i])
            
            self.view.addConstraint(centerYConsraint)
            
            validationButtonsCenterConstraint.append(centerYConsraint)
            
            newSwipeValidationIndicator.alpha = 0.0
            
            newSwipeValidationIndicator.animateAlpha(on: true)
            
            newSwipeValidationIndicator.addTarget(self, action: #selector(validationButtonPressed(_:)), for: .touchUpInside)
            
            swipeValidationIndicator.append(newSwipeValidationIndicator)
            
        }
    }
    @IBAction func validationButtonPressed(_ sender: UIButton!) {
        
        guard let palette = palettes.last else {
            print("no palette")
            return
        }
        
        for tile in self.palettes.last!.tiles {
            self.colors.append((tile.back.backgroundColor?.toHexString())!)
        }
        
        let on = sender == swipeValidationIndicator.last ? true : false //Check what button is clicked
        
        angleFactor = on == true ? 1 : -1
        
        

        UIView.animate(withDuration: 0.3) {
            palette.transform = CGAffineTransform(rotationAngle: CGFloat.pi/12 * self.angleFactor!)
            self.palettes.first?.alpha = 1.0
            self.palettes.first?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {

            palette.frame.origin.x = on == true ? 700 : -700
            palette.frame.origin.y -= 20
        }) { (_) in
            self.animateCardOut(palette, out: true)
        }
        
        
    }
    //MARK: - Return Button
    func addReturnButton() {
        
        if returnButton != nil {returnButton.removeFromSuperview()}
        
        guard let palette = palettes.last, let slider = sliders.last else {
            print("no palette or sliders")
            return
        }
        
        let buttonSize:CGFloat = 40
        let sliderPosition = slider.frame.origin
        let palettePosition = palette.frame.origin.y + palette.frame.size.height
        
        let distanceFromPallet = (sliderPosition.y - palettePosition)/2
        
        returnButton = UIButton()
        
        returnButton.backgroundColor = .gray
        returnButton.layer.cornerRadius = buttonSize/2
        returnButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        returnButton.isEnabled = false
        returnButton.tintColor = .white
        returnButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        if traitCollection.userInterfaceStyle == .dark {
            returnButton.layer.shadowRadius = 6
            returnButton.layer.shadowColor = UIColor.white.cgColor
            returnButton.layer.shadowOpacity = 0.5
        }
        returnButton.alpha = 0.0
        
        self.view.addSubview(returnButton)
        
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([returnButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor, constant: -distanceFromPallet),
                                     returnButton.centerXAnchor.constraint(equalTo: slider.centerXAnchor, constant: 0),
                                     returnButton.widthAnchor.constraint(equalToConstant: buttonSize),
                                     returnButton.heightAnchor.constraint(equalToConstant: buttonSize)])
        
        returnButton!.addTarget(self, action: #selector(returnPressed(_:)), for: .touchUpInside)
    }
    @IBAction func returnPressed(_ sender: UIButton){
        
        let feedBack = UINotificationFeedbackGenerator()
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        returnTapCount += 1
        
        let notification = Notification.Name(rawValue: sliderBeganNotificationKey)
        let sliderStartTime = CFAbsoluteTimeGetCurrent()
        NotificationCenter.default.post(name: notification, object: nil, userInfo: ["start":sliderStartTime])
        

        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.2
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.toValue = CGPoint(x: 1.1, y: 1.1)
        
        returnButton?.layer.add(animation, forKey: nil)
        
        if returnTapCount > Double(colorSave.count) {
            returnTapCount = 0.0
            
            feedBack.notificationOccurred(.error)
            
            returnButton?.isEnabled = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.returnButton?.backgroundColor = .red
            }) { (finished) in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.returnButton?.backgroundColor = .gray
                }, completion: {(ended) in
                    self.sliderTimer.invalidate()
                    self.returnIsPresenting = false
                    self.animateInteractionButtons(on: false)
                    self.colorSave = [UIColor]() //empty the array
                })
            }
            
            let anticlockAnimation = CABasicAnimation(keyPath: "transform.rotation")
            anticlockAnimation.fromValue = CGFloat.pi * 2
            anticlockAnimation.toValue = 0 //CGAffineTransform(rotationAngle: 0)
            anticlockAnimation.isAdditive = true
            anticlockAnimation.duration = 0.6
            anticlockAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.returnButton?.layer.add(anticlockAnimation, forKey: "rotate")
            
            
 
        }else{
            if let tile = palettes.last?.activeTile {
                
                feedBack.notificationOccurred(.success)
                
                let color = colorSave[Int(returnTapCount)-1]
                tile.back.backgroundColor = color
                animateSliders(forTile: tile)
                tile.label.adjustTextColor(color: color)
                tile.infoButton.adjustTextColor(color: color)
                
            }
        }
    }
    func animateInteractionButtons(on: Bool) {
        
        if returnIsPresenting {return}
        
        returnIsPresenting = on
        
        self.returnButton.isEnabled = on == true ? true : false
        
        self.returnButton.animateAlpha(on: on, withDuration: 0.2)
        
        let xMotion:CGFloat = on == true ? 30 : -30
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {

            self.validationButtonsCenterConstraint.first?.constant += -xMotion
            self.validationButtonsCenterConstraint.last?.constant += +xMotion
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    //MARK: - Transitions
    func goToColorDetail() {

        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)

        if let safeTile = palettes.last?.activeTile {
            safeTile.hexaCode = safeTile.back.backgroundColor?.toHexString()
            safeTile.redCode = Int((safeTile.back.backgroundColor?.rgb.red)! * 255)
            safeTile.greenCode = Int((safeTile.back.backgroundColor?.rgb.green)! * 255)
            safeTile.blueCode = Int((safeTile.back.backgroundColor?.rgb.blue)! * 255)

            guard let destinationVC = storyboard?.instantiateViewController(identifier: "ColorDetailController") as? ColorDetailControler else {
                return
            }

            destinationVC.delegate = self
            destinationVC.color = safeTile.back.backgroundColor

            let originPoint = safeTile.convert(safeTile.frame.origin, to: self.view)
            let tileRect = CGRect(origin: originPoint, size: safeTile.frame.size)

            destinationVC.originRect = tileRect

            self.addChild(destinationVC)
            self.view.addSubview(destinationVC.view)

        }
    }
}
//MARK: - Extensions
extension ViewController: PaletteDelegate {
    func tileLongTapped(tile: Tile) {
        if palettes.last?.activeTile != nil {
            palettes.last?.animateTile(on: false)
            colorSave = [UIColor]() //empty the array
        }
        palettes.last?.activeTile = tile
        palettes.last?.animateTile(on: true)
        palettes.last?.activeTile?.layer.removeAllAnimations()
        goToColorDetail()
    }
    func infoButtonPressed() {
        goToColorDetail()
    }
    func tileTapped(tile: Tile) {
        colorSave = [UIColor]() //empty the array
        animateSliders(forTile: tile)
        resetButton.animateGradient(startColor: tile.back.backgroundColor!)
    }
}
extension ViewController: ColorDetailControlerDelegate{
    func colorDetailDelegateDidDisapear() {
        palettes.last?.animateTile(on: false)
        palettes.last?.activeTile = nil
    }
}
extension ViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        action?.isEnabled = (newText.count > 0)
        
        return true
    }
}
extension ViewController: CustomNavBarDelegate {
    func navBarButtonPressed(index: Int) {

        func animateElementsOut(destinationVC: UIViewController, animated: Bool? = false) {
            
            let whiteOut = UIView(frame: CGRect(origin: CGPoint(x: 0.0, y: 100), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.height - 200)))
            whiteOut.backgroundColor = .white
            whiteOut.alpha = 0.0
            self.view.addSubview(whiteOut)
            
            addAnimator()
            animator.startAnimation()
            let _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
                whiteOut.removeFromSuperview()
                
                self.navigationController?.pushViewController(destinationVC, animated: animated!)
                timer.invalidate()
            }
        }
        
        if index == 1 {
            guard let destinationVC = storyboard?.instantiateViewController(identifier: "CollectionController") as? CollectionController else {
                print("no VC")
                return
            }
            destinationVC.delegate = self
            animateElementsOut(destinationVC: destinationVC)
        }else if index == 0 {
            guard let destinationVC = storyboard?.instantiateViewController(identifier: "PhotoViewController") as? PhotoViewController else {
                print("no VC")
                return
            }
            destinationVC.delegate = self
            
            let transition = CATransition.init()
            transition.duration = 0.45
            transition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.push //Transition you want like Push, Reveal
            transition.subtype = CATransitionSubtype.fromLeft // Direction like Left to Right, Right to Left
            transition.delegate = self
            view.window!.layer.add(transition, forKey: kCATransition)
            
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    func addAnimator(on: Bool? = true) {
        
        animator = nil
        animator = UIViewPropertyAnimator(duration: 0.34, curve: .easeInOut) {
            if on! {
                self.navBar.frame.origin.y += 89
                self.resetButton.alpha = 0.0
                self.resetButtonBackView.alpha = 0.0
                self.returnButton.alpha = 0.0
                self.sliders.forEach({$0.alpha = 0.0})
                self.swipeValidationIndicator.forEach({$0.alpha = 0.0})
                self.palettes.last?.alpha = 0.0
                self.palettes.last?.frame.origin.y -= 200
                self.view.layoutIfNeeded()
            }else{
                self.navBar.frame.origin.y = self.view.frame.size.height + self.screenAdjustment
                self.resetButton.alpha = 1.0
                self.resetButtonBackView.alpha = 1.0
                self.sliders.forEach({$0.alpha = 1.0})
                self.swipeValidationIndicator.forEach({$0.alpha = 1.0})
                self.palettes.last?.alpha = 1.0
                self.palettes.last?.frame.origin.y = 120 - self.screenAdjustment*3
            }
        }
    }
}
extension ViewController: CollectionControllerDelegate{
    func photoVCDidDisapearFromCollectionVC(color: UIColor, option: String) {
        PhotoVCDidDisapear(color: color, option: option)
    }
    

    func collectionControllerDidDisapearWithNoSelection(editingMode: Bool){
        self.editingMode = editingMode
        loadAnimation()
    }

    func collectionControllerDidDisapearWithSeletion(topColor: String, secondColor: String, thirdColor: String, bottomColor: String, editingMode: Bool, palletName: String) {
        
        let colors = [topColor,thirdColor,secondColor,bottomColor]
        
        palettes.last?.updateColors(color: .red, colors: colors)

        print("collection disapear: \(editingMode)")

        self.editingMode = editingMode

        self.paletteName = palletName

        loadAnimation()
    }
    func collectionViewAnimatePallet() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
}
extension ViewController: PhotoViewControllerDelegte {
    func PhotoVCDidDisapear(color: UIColor,option: String) {

        let palette = palettes.last!
        
        switch option {
        case k.analog:
            editingMode = false
            
            let colors = [color,
                          color.withHueOffset(offset: 1/18),
                          color.withHueOffset(offset: 2/18),
                          color.withHueOffset(offset: 3/18)]
            
            for (i,tile) in  palette.tiles.enumerated() {
                tile.back.backgroundColor = colors[i]
            }
            
            resetButton.animateGradient(startColor: color)
            
        default:
            if color.getWhiteAndAlpha.white > 0.5 {
                
                for (i,tile) in  palette.tiles.enumerated() {
                    tile.back.backgroundColor = color.darken(by: CGFloat(10 * i))
                }
                
            }else{
                
                for (i,tile) in  palette.tiles.enumerated() {
                    tile.back.backgroundColor = color.lighten(by: CGFloat(10 * i))
                }
                
            }
            resetButton.animateGradient(startColor: color)
        }
    }
}
extension ViewController: CAAnimationDelegate {
    
}
