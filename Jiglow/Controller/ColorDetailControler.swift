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
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    var mainColor: UIColor?
    var leftColor: UIColor?
    var middleColor: UIColor?
    var rightColor: UIColor?
    var hexaCode: String?
    var redCode: Int?
    var greenCode: Int?
    var blueCode: Int?
    
    var gauges = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDetailController()
        
//        roundedView.layer.cornerRadius = 5
//        shadowView.layer.shadowRadius = 2
//        shadowView.layer.shadowOpacity = 0.234
//        shadowView.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpGauges(relativeTo: lblRed,color: .systemRed)
            setUpGauges(relativeTo: lblGreen, color: .systemGreen)
            setUpGauges(relativeTo: lblBlue, color: .systemBlue)
        animateGauges(gauge: gauges[0], width: Double(redCode!)/255*130)
        animateGauges(gauge: gauges[1], width: Double(greenCode!)/255*130)
        animateGauges(gauge: gauges[2], width: Double(blueCode!)/255*130)
        
    }
    func setUpGauges(relativeTo label:UILabel, color: UIColor){
        let origin = label.convert(label.frame.origin, to: self.view)
        let newGauge = UIView(frame:CGRect(x: label.frame.origin.x + label.frame.width + 50, y: origin.y, width: 26, height: 26))
        newGauge.translatesAutoresizingMaskIntoConstraints = false
        newGauge.backgroundColor = color
        newGauge.frame.size = CGSize(width: 26, height: 24)
        
        gauges.append(newGauge)
        
        self.view.addSubview(newGauge)
        
        newGauge.layer.cornerRadius = 12
       
    }
    func animateGauges(gauge: UIView, width: Double){
        if width > 26{
            UIView.animate(withDuration: 1, delay: 0.0 ,animations: {
                gauge.frame.size.width = CGFloat(width)
            }, completion: nil)
        }
    }
    func setUpDetailController() {
        
        colorView.backgroundColor = mainColor
        secondColor1.backgroundColor = leftColor
        secondColor2.backgroundColor = middleColor
        secondColor3.backgroundColor = rightColor
        lblHexaCode.text = hexaCode
        lblHexaCode.textColor = mainColor
//        addParallaxToView(vw: lblHexaCode)
        lblRed.text = String(redCode!)
        lblGreen.text = String(greenCode!)
        lblBlue.text = String(blueCode!)
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.delegate?.colorDetailDelegateDidDisapear()

    }
}

