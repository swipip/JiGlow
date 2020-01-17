import UIKit
protocol PalletDelegate {
    func longPressOccured()
}
class Pallet: UIView, TileDelegate {    
    
    @IBOutlet var contentView: UIView!
    var topTile: Tile!
    var secondTile: Tile!
    var thirdTile: Tile!
    var bottomTile: Tile!
    var activeTile: Tile?
    
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
        
        topTile.contentView.backgroundColor = .systemOrange
        topTile.hexaLabel.text = topTile.contentView.backgroundColor!.toHexString()
        
        secondTile.contentView.backgroundColor = .systemYellow
        secondTile.hexaLabel.text = secondTile.contentView.backgroundColor!.toHexString()
        
        thirdTile.contentView.backgroundColor = .systemGreen
        thirdTile.hexaLabel.text = thirdTile.contentView.backgroundColor!.toHexString()
        
        bottomTile.contentView.backgroundColor = .systemBlue
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
        let height = 125.0
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
    }
    func addTileToView(with tile: Tile, height: Double, topAnchor constraint: Double) {
        contentView.addSubview(tile)
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(constraint)),
            tile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tile.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            tile.heightAnchor.constraint(equalToConstant: CGFloat(height))
        ])
    }
    //MARK: - Delegate methods
    func didTapTile() {
        //A tile got tapped
        for i in 1...4 {
            if Tiles[i]?.tileIsActive == true {
                if activeTile == Tiles[i] {
                    activeTile?.transformOff()
                    activeTile?.tileIsActive = false
                    activeTile = nil
                }else{
                    activeTile = Tiles[i]
                    activeTile?.transformOn()
                    activeTile?.tileIsActive = false
                }
            }else if Tiles[i]?.tileIsActive == false{
                Tiles[i]?.transformOff()
            }
        }
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
        delegate?.longPressOccured()
    }
}
