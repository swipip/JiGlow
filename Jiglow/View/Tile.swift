import Foundation
import UIKit

protocol TileDelegate {
    func didTapTile()
    func didLongPress()
    func infoButtonPressed(sender: Tile)
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
    var info: UIButton?
    
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
        
        addInfoButton()
        
    }
    func addInfoButton() {
        
        info = UIButton()
        info!.backgroundColor = .clear
        info!.tintColor = .white
        info!.addShadow()
        info!.setImage(UIImage(systemName: "info.circle"), for: .normal)
        info!.alpha = 0.0
        
        self.contentView.addSubview(info!)
        
        info!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([info!.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 5),
                                     info!.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 5),
                                     info!.widthAnchor.constraint(equalToConstant: 40),
                                     info!.heightAnchor.constraint(equalToConstant: 40)])
        


        
        info?.addTarget(self, action: #selector(infoPressed), for: .touchUpInside)
    }
    @IBAction func infoPressed() {
        delegate?.infoButtonPressed(sender: self)
    }
    func animateInfoButton() {
        let circle = UIView()
        
        circle.backgroundColor = .clear
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.borderWidth = 0.2
        circle.layer.cornerRadius = 10
        self.contentView.insertSubview(circle, at: 0)
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([circle.centerYAnchor.constraint(equalTo: self.info!.centerYAnchor, constant: 0),
                                     circle.centerXAnchor.constraint(equalTo: self.info!.centerXAnchor, constant: 0),
                                     circle.widthAnchor.constraint(equalToConstant: 20),
                                     circle.heightAnchor.constraint(equalToConstant: 20)])
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            circle.transform = CGAffineTransform(scaleX: 5, y: 5)
            circle.alpha = 0.0
        }, completion: nil)
    }
    //MARK: - Custom Methods
    func transformOn() {
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.info?.alpha = 1.0
            self.contentView.layer.cornerRadius = 10
        },completion: nil)
    }
    func transformOff(){
        UIView.animate(withDuration: 0.2, delay: 0,options: UIView.AnimationOptions.curveEaseInOut,animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.info?.alpha = 0.0
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
        self.hexaLabel.adjustTextColor(color: contentView.backgroundColor!)
        animateLabelAlphaOn()
        animateInfoButton()
        let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.animateInfoButton()
        }
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


