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
        
    }
    override func layoutSubviews() {
        
        super.layoutSubviews()
        tileStack.clipsToBounds = true
        tileStack.layer.cornerRadius = 5
        cornerView.layer.cornerRadius = 10
        cornerView.clipsToBounds = true
//        shadowView.layer.shadowRadius = 4
//        shadowView.layer.shadowOpacity = 0.0
//        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
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
