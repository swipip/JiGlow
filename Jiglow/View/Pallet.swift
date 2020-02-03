import UIKit
protocol PalletDelegate {
    func tileTapped()
    func tileLongTapped()
}
class Pallet: UIView, TileDelegate {    
    
    @IBOutlet var contentView: UIView!
    var topTile: Tile!
    var secondTile: Tile!
    var thirdTile: Tile!
    var bottomTile: Tile!
    var activeTile: Tile?
    var rotated:(on: Bool,dir: rotatedCases) = (false,.right)
    
    var Tiles = [Int: Tile]()
    
    var delegate: PalletDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tileColor:UIColor = .systemOrange
        
        topTile.contentView.backgroundColor = tileColor
        topTile.hexaLabel.text = topTile.contentView.backgroundColor!.toHexString()
        
        secondTile.contentView.backgroundColor = tileColor.lighten(by: 10)
        secondTile.hexaLabel.text = secondTile.contentView.backgroundColor!.toHexString()
        
        thirdTile.contentView.backgroundColor = tileColor.lighten(by: 20)
        thirdTile.hexaLabel.text = thirdTile.contentView.backgroundColor!.toHexString()
        
        bottomTile.contentView.backgroundColor = tileColor.lighten(by: 30)
        bottomTile.hexaLabel.text = bottomTile.contentView.backgroundColor!.toHexString()
        
    }
    func commonInit() {
        Bundle.main.loadNibNamed("Pallet", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        setUpTiles()
        
        topTile.delegate = self
        secondTile.delegate = self
        thirdTile.delegate = self
        bottomTile.delegate = self
        
    }
    func setUpTiles() {
        let height = Double(0.15 * UIScreen.main.bounds.size.height)
        var compoundedHeight = 0.0
        for index in 1...4 {
            Tiles[index] = Tile()
            switch index {
            case 1:
                topTile = Tiles[index]
                topTile.rank = 1
            case 2:
                secondTile = Tiles[index]
                secondTile.rank = 2
            case 3:
                thirdTile = Tiles[index]
                thirdTile.rank = 3
            case 4:
                bottomTile = Tiles[index]
                bottomTile.rank = 4
            default:
                break
            }
            addTileToView(with: Tiles[index]!, height: height/Double(index), topAnchor: compoundedHeight)
            
            compoundedHeight += height/Double(index)
        }
        NSLayoutConstraint.activate([contentView.heightAnchor.constraint(equalToConstant: CGFloat(compoundedHeight))])
    }
    func addTileToView(with tile: Tile, height: Double, topAnchor constraint: Double) {
        
        contentView.addSubview(tile)
        //constraints
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tile.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(constraint)),
                                     tile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
                                     tile.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
                                     tile.heightAnchor.constraint(equalToConstant: CGFloat(height))
        ])
    }
    //MARK: - Rotation Handlers
    func rotateSquare(angle: CGFloat){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = self.transform.rotated(by: angle)
        })
        
    }
    enum rotatedCases {
        case right, left
    }
    func rotate() {
        
        if self.rotated.on == false {
            // view is not in rotated state
            if self.rotated.dir == .right {
                
                self.rotateSquare(angle: CGFloat(Double.pi / 32))
                
            }else{
                
                self.rotateSquare(angle: -CGFloat(Double.pi / 32))
                
            }
        }else{
            //view is not in a rotated state
            if self.rotated.dir == .right{
                self.rotateSquare(angle: -CGFloat(Double.pi / 32))
                self.rotated.on = false
            }else{
                self.rotateSquare(angle: +CGFloat(Double.pi / 32))
                self.rotated.on = false
            }
        }
        
    }
    
    //MARK: - Delegate methods
    func didTapTile() {
        //A tile got tapped
        for i in 1...4 {
            if Tiles[i]?.tileIsActive == true {
                if activeTile == Tiles[i] {
                    activeTile?.transformOff()
                    activeTile?.tileIsActive = false
                    activeTile?.animateLabelAlphaOff()
                    activeTile = nil
                }else{
                    activeTile = Tiles[i]
                    activeTile?.transformOn()
                    activeTile?.tileIsActive = false
                }
            }else if Tiles[i]?.tileIsActive == false{
                Tiles[i]?.transformOff()
                Tiles[i]?.animateLabelAlphaOff()
            }
        }
        delegate?.tileTapped()
    }
    func didLongPress() {
        for tile in Tiles{
            if tile.value.tileIsActive == true{
                activeTile = tile.value
                activeTile?.transformOn()
            }else{
                tile.value.transformOff()
            }
        }
        delegate?.tileLongTapped()
    }
}
