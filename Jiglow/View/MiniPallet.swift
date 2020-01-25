import UIKit

class MiniPallet: UICollectionViewCell {

    
    @IBOutlet private weak var tileStack: UIView!
    @IBOutlet private weak var topTile: UIView!
    @IBOutlet private weak var secondTile: UIView!
    @IBOutlet private weak var thirdTile: UIView!
    @IBOutlet private weak var bottomTile: UIView!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var palletNameLabel: UILabel!
    
    var topTileColor: UIColor?
    var secondTileColor: UIColor?
    var thirdTileColor: UIColor?
    var bottomTileColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    @objc func tapHandler() {
//        print("tapped")
    }
    override func layoutSubviews() {
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        
//        cornerView.addGestureRecognizer(tapGesture)
        
        super.layoutSubviews()
        tileStack.clipsToBounds = true
        tileStack.layer.cornerRadius = 5
        cornerView.layer.cornerRadius = 10
        cornerView.clipsToBounds = true
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    func updateColor(top: UIColor, second:UIColor, third: UIColor, bottom: UIColor) {
        
        topTile.backgroundColor = top
        secondTile.backgroundColor = second
        thirdTile.backgroundColor = third
        bottomTile.backgroundColor = bottom
        
    }
    func updateColorCD(top: String, second: String, third: String, bottom: String){
        topTile.backgroundColor = UIColor(hexString: top)
        secondTile.backgroundColor = UIColor(hexString: second)
        thirdTile.backgroundColor = UIColor(hexString: third)
        bottomTile.backgroundColor = UIColor(hexString: bottom)
    }
}
extension UIColor {
    convenience init(hexString: String) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) //1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
