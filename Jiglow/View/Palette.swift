//
//  Palette.swift
//  JiglowRevised
//
//  Created by Gautier Billard on 22/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
protocol PaletteDelegate {
    func tileTapped(tile: Tile)
    func tileLongTapped(tile: Tile)
    func infoButtonPressed()
}
class Palette: UIView {

    var numberOfTiles: Int?
    var tiles = [Tile]()
    private var height: Double!
    var activeTile: Tile?
    private var width: Double!
    private var originY: CGFloat!
    private var tileIsPresenting = false
    
    var delegate: PaletteDelegate?
    
    private var testTops = [NSLayoutConstraint]()
    private var widths = [NSLayoutConstraint]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.height = Double(frame.size.height) / 4
        self.width = Double(frame.size.width)
        addTiles()
        addShadow()

        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.bounds.contains(point) {
            self.activeTile?.layer.removeAllAnimations()
            return true
        }else{
            return false
        }
    }

    private func addTiles() {
        let color = UIColor.systemGray
        let colors = [color,color.lighten(by:10),color.lighten(by:20),color.lighten(by:30)]
        
        let numberOfTiles = self.numberOfTiles ?? 4
        
        var topAnch:CGFloat = 5.0
        let height = CGFloat(self.height * 4)
        
        let heights = [height * 0.4,height * 0.25, height * 0.20,height * 0.15]
        
        tiles.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        
        for i in 0...numberOfTiles-1 {
            
            let newTile = Tile(frame: CGRect(x: 5.0, y: Double(topAnch-0.5), width: self.width!, height: Double(heights[i])))
            newTile.back.backgroundColor = colors[i]
            newTile.delegate = self
            
            let radius:CGFloat = 12
            
            if i == 0 {
                newTile.roundCorners([.topLeft,.topRight], radius: radius)
            }else if i == numberOfTiles - 1 {
                newTile.roundCorners([.bottomLeft,.bottomRight], radius: radius)
            }
            
            addSubview(newTile)
            
            tiles.append(newTile)
            
            topAnch += heights[i]
            
        }
        
    }
    private func addShadow() {
        
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 9
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        layer.shadowOpacity = 0.3
        
    }
    func animateTile(on: Bool) {
        
        var margin:CGFloat = on == true ? 10.0 : -10.0
        
        if self.activeTile == nil { self.activeTile = tiles[1]}
        
        if tileIsPresenting == on {return}
        
        tileIsPresenting = on
        
        if on {originY = activeTile?.frame.origin.y}
        
        guard let activeTile = activeTile else {
            print("no active tile to animate")
            return
        }
        
        activeTile.animateElements(on: on)
        
        var rank = 0
        
        for (i,tile) in tiles.enumerated() {
            if tile == activeTile {
                rank = i
            }
        }

        func layoutSelectedTile(rank: Int,upTile: Tile? = nil, downTile: Tile? = nil, upTileCorners: UIRectCorner, downTileCorners: UIRectCorner) {
            
            if rank < 2 {
                margin *= -1
            }
            
            let scale:CGFloat = on == true ? 1.05 : 1.0
            
            if on == false {
                for (i,tile) in tiles.enumerated() {
                    if i != 0 && i != tiles.count - 1 {
                        UIView.animate(withDuration: 0.2) {
                            tile.roundCorners([], radius: 0)
                        }
                    }
                }
                UIView.animate(withDuration: 0.3) {
                    self.tiles.first?.roundCorners([.topRight, .topLeft], radius: 12)
                    self.tiles.last?.roundCorners([.bottomLeft, .bottomRight], radius: 12)
                }
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                
                upTile?.frame.origin.y += downTile == nil ? 0 : margin * 2
                
                self.activeTile?.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.activeTile?.frame.origin.y += margin
                if on {
                    self.activeTile?.roundCorners([.topRight,.topLeft,.bottomRight,.bottomLeft], radius: 12)
                    upTile?.roundCorners(upTileCorners, radius: 12)
                    downTile?.roundCorners(downTileCorners, radius: 12)
                }
                
            }, completion: nil)
            self.activeTile?.layer.cornerRadius = 12
            
            if on {
                let floatAmp:CGFloat = 3.0
                self.activeTile?.frame.origin.y -= floatAmp/2
                UIView.animate(withDuration: 1.3, delay: 0, options: [.repeat,.autoreverse], animations: {
                    self.activeTile?.frame.origin.y += floatAmp
                }, completion: nil)
            }else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.activeTile?.frame.origin.y = self.originY
                }, completion: nil)
            }
            
        }
        
        switch rank {
        case 0:
            
            let downTile = tiles[rank + 1]
            
            layoutSelectedTile(rank: rank, upTile: nil, downTile: downTile, upTileCorners: [], downTileCorners: [.topRight, .topLeft])
            
        case tiles.count - 1:
            
            let upTile = tiles[rank - 1]
            
            layoutSelectedTile(rank: rank, upTile: upTile, downTile: nil, upTileCorners: [.bottomRight, .bottomLeft], downTileCorners: [])
            
        case 1:
            
            let downTile = tiles[rank + 1]
            let upTile = tiles[rank - 1]
            
            layoutSelectedTile(rank: rank, upTile: upTile, downTile: downTile, upTileCorners: [.bottomRight, .bottomLeft, .topRight,.topLeft], downTileCorners: [.topRight, .topLeft])
            
        case 2:
            
            let downTile = tiles[rank + 1]
            let upTile = tiles[rank - 1]
            
            layoutSelectedTile(rank: rank, upTile: downTile, downTile: upTile, upTileCorners: [.bottomRight, .bottomLeft, .topRight,.topLeft], downTileCorners: [.bottomRight, .bottomLeft])
            
        default:
            break
        }
        
    }
    func updateColors(color: UIColor, colors: [String]? = nil){
        var delay = 0.0
        
        for (i,tile) in tiles.enumerated() {
            UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut, animations: {
                if let colors = colors {
                    tile.back.backgroundColor = UIColor(hexString: colors[i])
                }else{
                    tile.back.backgroundColor = color.lighten(by: CGFloat((i) * 10))
                }
                
                
            }, completion: nil)
            delay += 0.05
            
        }
        
    }
}
extension Palette: TileDelegate {
    func didLongPress(sender: Tile) {
        delegate?.tileLongTapped(tile: sender)
    }
    
    
    func infoButtonPressed(sender: Tile) {
        delegate?.infoButtonPressed()
    }
    
    func didTapTile(sender: Tile) {
        
        delegate?.tileTapped(tile: sender)
        
        self.activeTile?.layer.removeAllAnimations()
        
        if activeTile == nil  {
            activeTile = sender
            animateTile(on: true)
            return
        }else if activeTile == sender {
            animateTile(on: false)
            activeTile = nil
            return
        }else{
            animateTile(on: false)
            activeTile = sender
            animateTile(on: true)
            return
        }
    }
    
}
