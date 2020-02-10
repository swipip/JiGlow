import Foundation
import UIKit

protocol TileDelegate {
    func didTapTile()
    func didLongPress()
}
enum tapType {
    case short,long
}
class Tile: UIView {
    
    var hexaCode: String?
    var redCode: Int?
    var blueCode: Int?
    var greenCode: Int?
    var color: UIColor?
    var rank: Int?
    var delegate: TileDelegate?
    var tileWidth = 0.0
    var tileIsActive = false
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var hexaLabel: ColorLabel!
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        tileWidth = Double(self.frame.width)
    }
    func commonInit() {
        Bundle.main.loadNibNamed("Tile", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        let tapTile = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        contentView.addGestureRecognizer(tapTile)
        
        let longTapTile = UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler))
        longTapTile.minimumPressDuration = 0.2
        contentView.addGestureRecognizer(longTapTile)
        
        self.hexaLabel.alpha = 0.0
        
    }
    //MARK: - Custom Methods
    func transformOn() {
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.contentView.layer.cornerRadius = 10
        },completion: nil)
    }
    func transformOff(){
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentView.layer.cornerRadius = 0
        },completion: nil)
    }
    func animateLabelAlphaOn(){
        UIView.animate(withDuration: 0.2, animations: {
            self.hexaLabel.alpha = 1.0
        }, completion: nil)
    }
    func animateLabelAlphaOff(){
        UIView.animate(withDuration: 0.2, animations: {
            self.hexaLabel.alpha = 0.0
        }, completion: nil)
    }
//MARK: - Delegate Methods
    @objc func tapHandler() {
        tileIsActive  = true
        self.hexaLabel.adjustTextColor(red: (contentView.backgroundColor?.rgb.red)!, green: (contentView.backgroundColor?.rgb.green)!, blue: (contentView.backgroundColor?.rgb.blue)!)
        animateLabelAlphaOn()
        delegate?.didTapTile()
    }
    @objc func longTapHandler(sender: AnyObject) {
        tileIsActive = true
        if let safeSender = sender as? UILongPressGestureRecognizer{
            if safeSender.state == .began{
                delegate?.didLongPress()
            }
        }
    }
}
//MARK: - Extensions


