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
    @IBOutlet weak var gaugesView: UIView!
    
    var mainColor: UIColor?
    var leftColor: UIColor?
    var middleColor: UIColor?
    var rightColor: UIColor?
    var hexaCode: String?
    var redCode, greenCode, blueCode: Int?
    
    private var gauges = [UIView]()
    private var labels = [UILabel]()
    private var redWidthConstraint: NSLayoutConstraint?
    private var greenWidthConstraint: NSLayoutConstraint?
    private var blueWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDetailController()
        setUpGauges()
        setUpLabels()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLabels(code: redCode!, label: labels[0])
        animateLabels(code: greenCode!, label: labels[1])
        animateLabels(code: blueCode!, label: labels[2])
        animateGauges(gauge: redWidthConstraint!, width: Double(redCode!)/255*130)
        animateGauges(gauge: greenWidthConstraint!, width: Double(greenCode!)/255*130)
        animateGauges(gauge: blueWidthConstraint!, width: Double(blueCode!)/255*130)
        
    }
    func setUpGauges(){
        let gaugeHeight: CGFloat = 32
        var topAnchorVar:CGFloat = (self.gaugesView.frame.size.height - gaugeHeight * 3)/4
        for i in 1...3 {
            let newGauge = UIView()
            
            gauges.append(newGauge)
            newGauge.layer.cornerRadius = gaugeHeight/2
            self.view.addSubview(newGauge)
            
            newGauge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newGauge.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                         newGauge.topAnchor.constraint(equalTo: self.gaugesView.topAnchor, constant: topAnchorVar),
                                         newGauge.heightAnchor.constraint(equalToConstant: gaugeHeight)])
            switch i {
            case 1:
                newGauge.backgroundColor = .systemRed
                redWidthConstraint = NSLayoutConstraint(item: newGauge, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: gaugeHeight)
                self.view.addConstraint(redWidthConstraint!)
                topAnchorVar += gaugeHeight + 4
            case 2:
                newGauge.backgroundColor = .systemGreen
                greenWidthConstraint = NSLayoutConstraint(item: newGauge, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: gaugeHeight)
                self.view.addConstraint(greenWidthConstraint!)
                topAnchorVar += gaugeHeight + 4
            case 3:
                newGauge.backgroundColor = .systemBlue
                blueWidthConstraint = NSLayoutConstraint(item: newGauge, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: gaugeHeight)
                self.view.addConstraint(blueWidthConstraint!)
            default:
                break
            }
            
        }
    }
    func setUpLabels(){
        
        for i in 0...2 {
            
            let newLabel = UILabel()
            newLabel.text = "0"
            newLabel.textAlignment = .right
            newLabel.textColor = .white
            newLabel.font = UIFont(name: "system", size: 11)
            self.view.addSubview(newLabel)
            
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newLabel.trailingAnchor.constraint(equalTo: gauges[i].trailingAnchor, constant: -6),
                                         newLabel.topAnchor.constraint(equalTo: gauges[i].topAnchor, constant: 0),
                                         newLabel.bottomAnchor.constraint(equalTo: gauges[i].bottomAnchor, constant: 0),
                                         newLabel.widthAnchor.constraint(equalToConstant: 50)])
            
            labels.append(newLabel)
            
        }
        
    }
    func animateGauges(gauge: NSLayoutConstraint, width: Double){
        if width > 34{
            UIView.animate(withDuration: 1, delay: 0.0,options: .curveEaseInOut ,animations: {
                gauge.constant = CGFloat(width) * 1.2
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func animateLabels(code: Int, label: UILabel){
        
        var rgbCode:Double = 0
        let code = code == 0 ? 0.0001 : Double(code)
        let timeInterval = 1 / code
        
        let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true) { (timer) in
            if rgbCode == code {
                timer.invalidate()
            }else{
                rgbCode += 1
                label.text = String(Int(rgbCode))
            }
        }
    }
    func setUpDetailController() {
        
        colorView.backgroundColor = mainColor
        secondColor1.backgroundColor = leftColor
        secondColor2.backgroundColor = middleColor
        secondColor3.backgroundColor = rightColor
        lblHexaCode.text = hexaCode
        let red = (mainColor?.rgb.red)!
        let green = (mainColor?.rgb.green)!
        let blue = (mainColor?.rgb.blue)!
        lblHexaCode.adjustTextColor(red: red, green: green, blue: blue)
  
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.delegate?.colorDetailDelegateDidDisapear()

    }
}

