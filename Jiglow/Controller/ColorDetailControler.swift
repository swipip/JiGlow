import Foundation
import UIKit

protocol ColorDetailControlerDelegate {
    func colorDetailDelegateDidDisapear()
}

class ColorDetailControler: UIViewController {
    
    var delegate: ColorDetailControlerDelegate?
    
    private var mainColorDisplay: UIView?
    private var mainColorDisplayHeight: NSLayoutConstraint!
    private var mainColorDisplayTop: NSLayoutConstraint!
    private var mainColorDisplayWidth: NSLayoutConstraint!
    private var gaugesConstraints = [NSLayoutConstraint]()
    private var dismissButton: UIButton?
    private var hexLabel: UILabel?
    private var gauges = [UIView]()
    private var gaugesBacks = [UIView]()
    private var gaugesLabels = [UILabel]()
    private var mainHeight: CGFloat?
    private var mainWidth: CGFloat?
    private var gaugesWidth: CGFloat?
    private var complView: UIView?
    
    var originRect: CGRect?
    var color:  UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        mainHeight = self.view.frame.size.height
        mainWidth = self.view.frame.size.width
        gaugesWidth =  (mainWidth! * 0.85)/2 - 10
        
        layoutViews()
        
    }
    override func viewDidLayoutSubviews() {
        dismissButton?.imageView?.contentMode = .scaleToFill
    }
    func layoutViews() {
        addMainSwipeGesture()
        addMainColorDisplay()
        addComplementaryColorView()
        addDismissButton()
        addGauges()
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
            
            if let color = self.color {
                let red = Double(color.rgb.red)
                let green = Double(color.rgb.green)
                let blue = Double(color.rgb.blue)
                
                self.animateGauges(red: red, green: green, blue: blue)
            }
        }
        
    }
    func addMainSwipeGesture() {
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
    }
    @objc func swipeHandler() {
        dismissController()
    }
    func dismissController() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.mainColorDisplay?.frame.size.height = 0.0
            self.mainColorDisplay?.alpha = 0.0
            self.complView?.alpha = 0.0
            self.dismissButton?.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: {(ended) in
            self.removeFromParent()
            self.view.removeFromSuperview()
        })
    }
    func addMainColorDisplay(){
        
        let blurView = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurView)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.alpha = 1.0
        
        //        UIView.animate(withDuration: 0.5) {
        //            blurEffectView.alpha = 1.0
        //        }
        
        mainColorDisplay = UIView()
        mainColorDisplay!.frame = originRect ?? CGRect(x: 50, y: 50, width: 100, height: 100)
        
        self.view.addSubview(mainColorDisplay!)
        
        if let mainColorDisplay = self.mainColorDisplay {
            
            mainColorDisplay.backgroundColor = color
            mainColorDisplay.layer.cornerRadius = 12
            
            
            
            let height = mainColorDisplay.frame.size.height
            let width = mainColorDisplay.frame.size.width
            let top = mainColorDisplay.frame.origin.y + height
            
            mainColorDisplay.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([mainColorDisplay.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)])
            
            mainColorDisplayWidth = NSLayoutConstraint(item: mainColorDisplay, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
            mainColorDisplayHeight = NSLayoutConstraint(item: mainColorDisplay, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)
            mainColorDisplayTop = NSLayoutConstraint(item: mainColorDisplay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: top)
            
            self.view.addConstraints([mainColorDisplayHeight,mainColorDisplayTop,mainColorDisplayWidth])
            
            let duration = 0.8
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.18, options: .curveEaseInOut, animations: {
                self.mainColorDisplayTop.constant = 50
                self.view.layoutIfNeeded()
            }, completion: nil)
            UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.18, options: .curveEaseInOut, animations: {
                self.mainColorDisplayWidth.constant = self.mainWidth! * 0.85
                self.mainColorDisplayHeight.constant = self.mainHeight! * 0.6
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            // add Label for Hex code
            
            hexLabel = UILabel()
            
            if let hexLabel = self.hexLabel {
                
                hexLabel.alpha = 0.0
                hexLabel.text = color?.toHexString()
                hexLabel.font = UIFont.systemFont(ofSize: 30)
                hexLabel.adjustTextColor(color: mainColorDisplay.backgroundColor!)
                
                self.view.addSubview(hexLabel)
                
                hexLabel.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([hexLabel.bottomAnchor.constraint(equalTo: self.mainColorDisplay!.bottomAnchor, constant: 10),
                                             hexLabel.leadingAnchor.constraint(equalTo: self.mainColorDisplay!.leadingAnchor, constant: 20),hexLabel.heightAnchor.constraint(equalToConstant: 80)])
                
                
                UIView.animate(withDuration: 0.4) {
                    hexLabel.alpha = 1.0
                }
                
            }
            
        }
    }
    func addDismissButton() {
        
        dismissButton = UIButton()
        
        if let dismissButton = self.dismissButton {
            
            dismissButton.backgroundColor = .gray
            dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            dismissButton.tintColor = .white
            dismissButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            dismissButton.alpha = 0.0
            dismissButton.layer.cornerRadius = 20
            
            self.view.addSubview(dismissButton)
            
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([dismissButton.topAnchor.constraint(equalTo: self.complView!.bottomAnchor, constant: 10),
                                         dismissButton.trailingAnchor.constraint(equalTo: self.mainColorDisplay!.trailingAnchor, constant: 0),
                                         dismissButton.heightAnchor.constraint(equalToConstant: 40),
                                         dismissButton.widthAnchor.constraint(equalToConstant: 40)])
            
            self.dismissButton!.addTarget(self, action: #selector(dismissPressed(_:)), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                dismissButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                dismissButton.alpha = 0.8
            }) { (ended) in
                
            }
            
        }
        
    }
    @IBAction func dismissPressed(_ sender: UIButton!){
        
        
        //        self.dismiss(animated: true, completion: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
        
        
    }
    func addComplementaryColorView() {
        
        let red = 1 - color!.rgb.red
        let green = 1 - color!.rgb.green
        let blue = 1 - color!.rgb.blue
        let color = UIColor(red: Int(red*255), green: Int(green*255), blue: Int(blue*255))
        
        //        let color = UIColor.blue
        
        complView = UIView()
        if let complView = self.complView {
            complView.backgroundColor = color
            complView.transform = CGAffineTransform(scaleX: 0, y: 0)
            complView.layer.cornerRadius = 13
            
            self.view.addSubview(complView)
            
            complView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([complView.topAnchor.constraint(equalTo: self.mainColorDisplay!.bottomAnchor, constant: 10),
                                         complView.trailingAnchor.constraint(equalTo: self.mainColorDisplay!.trailingAnchor, constant: 0),
                                         complView.heightAnchor.constraint(equalToConstant: 100),
                                         complView.widthAnchor.constraint(equalToConstant: self.mainColorDisplay!.frame.size.width / 2 - 5)])
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = color.darken(by:10) //complView.backgroundColor.darken()
            backgroundView.clipsToBounds = true
            backgroundView.layer.cornerRadius = 12
            let corners:UIRectCorner = [.topLeft,.topRight]
            backgroundView.layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
            
            complView.addSubview(backgroundView)
            
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([backgroundView.topAnchor.constraint(equalTo: complView.topAnchor, constant: 0),
                                         backgroundView.trailingAnchor.constraint(equalTo: complView.trailingAnchor, constant: 0),
                                         backgroundView.heightAnchor.constraint(equalToConstant: 30),
                                         backgroundView.leadingAnchor.constraint(equalTo: complView.leadingAnchor, constant: 0)])
            
            let complLabel = UILabel()
            complLabel.text = color.toHexString()
            complLabel.adjustTextColor(color: color.darken(by: 10)!)
            
            backgroundView.addSubview(complLabel)
            
            complLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([complLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
                                         complLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 0)])
            
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                complView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            //Set gesture
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(complViewTapHandler))
            longPress.minimumPressDuration = 0.0
            complView.addGestureRecognizer(longPress)
        }
        
    }
    @objc func complViewTapHandler(recognizer: UILongPressGestureRecognizer) {
        
        let colorCompl = complView?.backgroundColor
        
        if let colorCompl = colorCompl, let colorInitial = self.color {
            let red = (compl: Double(colorCompl.rgb.red), initial: Double(colorInitial.rgb.red))
            let green = (compl: Double(colorCompl.rgb.green), initial: Double(colorInitial.rgb.green))
            let blue = (compl: Double(colorCompl.rgb.blue), initial: Double(colorInitial.rgb.blue))
            
            switch recognizer.state {
            case .began:
                animateComplView(factor: 1.05)
                animateGauges(red: red.compl, green: green.compl, blue: blue.compl)
                //            case .:
                
            case .ended:
                animateComplView(factor: 1.0)
                animateGauges(red: red.initial, green: green.initial, blue: blue.initial)
            default:
                print("default")
            }
        }
        
        
    }
    func animateComplView(factor: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.complView?.transform = CGAffineTransform(scaleX: factor, y: factor)
        }, completion: nil)
    }
    typealias CompletionHandler = (_ success:Bool) -> Void
    func addGauges(completionHandler: CompletionHandler? = nil) {
        
        var compoundedHeight:CGFloat = 10
        let gaugesHeight = (100-2*compoundedHeight)/3
        let colors = [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue]
        var delayForAnimation = 0.2
        
        for i in 0...2 {
            let newGaugeBack = UIView()
            newGaugeBack.backgroundColor = .lightGray
            newGaugeBack.layer.cornerRadius = gaugesHeight/2
            
            self.view.addSubview(newGaugeBack)
            
            newGaugeBack.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([newGaugeBack.topAnchor.constraint(equalTo: self.mainColorDisplay!.bottomAnchor, constant: compoundedHeight),
                                         newGaugeBack.widthAnchor.constraint(equalToConstant: gaugesWidth!),
                                         newGaugeBack.heightAnchor.constraint(equalToConstant: gaugesHeight),
                                         newGaugeBack.leadingAnchor.constraint(equalTo: self.mainColorDisplay!.leadingAnchor, constant: 0)])
            
            
            
            //gauges
            
            let newGauge = UIView()
            newGauge.backgroundColor = colors[i]
            newGauge.alpha = 0.0
            newGauge.layer.cornerRadius = gaugesHeight/2
            newGauge.layer.shadowRadius = 2
            newGauge.layer.shadowOpacity = 0.2
            newGauge.layer.shadowOffset = CGSize(width: 0.2, height: 0)
            
            self.view.addSubview(newGauge)
            
            newGauge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newGauge.leadingAnchor.constraint(equalTo: self.mainColorDisplay!.leadingAnchor, constant: 0),
                                         newGauge.topAnchor.constraint(equalTo: self.mainColorDisplay!.bottomAnchor, constant: compoundedHeight),
                                         newGauge.heightAnchor.constraint(equalToConstant: gaugesHeight)])
            
            let constraint = NSLayoutConstraint(item: newGauge, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0.2 * gaugesWidth! )
            
            gaugesConstraints.append(constraint)
            self.view.addConstraint(constraint)
            
            
            gaugesBacks.append(newGaugeBack)
            gauges.append(newGauge)
            
            
            compoundedHeight += gaugesHeight+10
            
            newGaugeBack.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            
            UIView.animate(withDuration: 0.3, delay: delayForAnimation, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.12, options: .curveEaseOut, animations: {
                newGaugeBack.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (ended) in
                
            }
            delayForAnimation += 0.1
            
            let newLabel = UILabel()
            newLabel.text = "0"
            newLabel.font = UIFont.systemFont(ofSize: 10)
            
            
            newLabel.textColor = .white
            
            newGauge.addSubview(newLabel)
            
            gaugesLabels.append(newLabel)
            
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newLabel.trailingAnchor.constraint(equalTo: newGauge.trailingAnchor, constant: -8),
                                         newLabel.centerYAnchor.constraint(equalTo: newGauge.centerYAnchor, constant: 0)])
        }
        completionHandler?(true)
    }
    func animateGauges(red: Double,green: Double, blue: Double) {
        
        let widths = [red,green,blue]
        
        for i in 0...2 {
            let width = widths[i] * Double(gaugesWidth!)
            
            UIView.animate(withDuration: 0.2) {
                self.gauges[i].alpha = 1.0
            }
            
            UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.gaugesConstraints[i].constant = CGFloat(width) < 0.2 * self.gaugesWidth! ? 0.2 * self.gaugesWidth! : CGFloat(width)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            let target = min(255,widths[i] * 255)
            let indent:Double = (target) * 1/60
            var number:Double = 0.0
            
            let _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
                number += indent
                if number >= target {
                    self.gaugesLabels[i].text = String(Int(target))
                    timer.invalidate()
                }else{
                    self.gaugesLabels[i].text = String(Int(number))
                }
            }
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.delegate?.colorDetailDelegateDidDisapear()
        
    }
}

