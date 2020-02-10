import Foundation
import UIKit

protocol SwipeControllerDelegate {
    func didFinishedAnimateReload()
    func didUpdatePalletPosition(position: CGFloat, direction: Direction)
    func panDidEnd(topColor: String, secondColor: String, thirdColor: String, bottomColor: String)
}
class SwipeController {
    
    var squares: [Pallet] = []
    var delegate: SwipeControllerDelegate?
    var originS: CGPoint?
    var currentS = CGPoint()
    var differenceFromXOrigin: CGFloat?
    var differenceFromYOrigin: CGFloat?
    var motherView: UIView
    var oldValue = false
    var myBool = false
    var notified = false
    var swipeLimit: CGFloat
    
    init(view: UIView) {
        motherView = view
        swipeLimit = motherView.frame.width/2 - 40
    }
    
    func animateCardInOut(finalPoint: CGPoint, view: UIView){
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        view.center = finalPoint },
                       completion: nil)
        
    }
    func animateReload(view: UIView) {
        self.motherView.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
//            view.alpha = 1
//            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (Bool) in
            self.squares.remove(at: 1)
            self.delegate?.didFinishedAnimateReload()

        }
        
    }
    func changeRotationDirection(recognizer: UIPanGestureRecognizer) {
        if currentS.x > motherView.getCenter().x {
            delegate?.didUpdatePalletPosition(position: CGFloat(differenceFromXOrigin! / 150),direction: .right)
            //view right hand
            if myBool != oldValue {
                squares[1].rotate()
                defineRotationDirection(recognizer: recognizer)
                oldValue = true //was right
                notified = false
            }
            myBool = true //is right
        }else{
            delegate?.didUpdatePalletPosition(position: CGFloat(differenceFromXOrigin! / 150),direction: .left)
            //view left hand
            if myBool != oldValue {
                squares[1].rotate()
                defineRotationDirection(recognizer: recognizer)
                oldValue = false //was left
                notified = false
            }
            myBool = false  //is left
        }
    }
    func defineRotationDirection(recognizer: UIPanGestureRecognizer) {
        if recognizer.velocity(in: squares[1]).x < 0 {
            squares[1].setAnchorPoint(CGPoint(x: 0.5, y: 0.9))
            squares[1].rotated = (true, .right)
            squares[1].rotate()
        }else{
            squares[1].setAnchorPoint(CGPoint(x: 0.5, y: 0.9))
            squares[1].rotated = (true, .left)
            squares[1].rotate()
        }
    }
    func handlePanEnded(velocity: CGPoint, recognizer: UIPanGestureRecognizer){
        if Float(differenceFromXOrigin!) >= Float(swipeLimit) {
            
            notified = false
            squares[1].rotate()
            
            let finalPoint = CGPoint(x:originS!.x + (velocity.x),
                                     y:originS!.y + (velocity.y))
            
            animateCardInOut(finalPoint: finalPoint, view: recognizer.view!)
            
            squares[1].setAnchorPoint(CGPoint(x: 0.5,y: 0.5))
            squares[1].removeFromSuperview()
//            squares[0].transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            //
            let middleX = motherView.getCenter().x
//            print("middle x \(middleX) current \(currentS.x)")
            if currentS.x > middleX {
                notification(type: .success)
                self.delegate?.panDidEnd(topColor: (squares[1].topTile.contentView.backgroundColor?.toHexString())!,
                secondColor: (squares[1].secondTile.contentView.backgroundColor?.toHexString())!,
                thirdColor: (squares[1].thirdTile.contentView.backgroundColor?.toHexString())!,
                bottomColor: (squares[1].bottomTile.contentView.backgroundColor?.toHexString())!)
            }else{
                notification(type: .error)
            }
            //
            animateReload(view: squares[0])
            
        }else if Float(differenceFromXOrigin!) < Float(swipeLimit) {
            
            squares[1].rotate()
            
            let finalPoint = CGPoint(x:originS!.x , y:originS!.y)
            self.squares[1].setAnchorPoint(CGPoint(x: 0.5 ,y: 0.5))
            animateCardInOut(finalPoint: finalPoint, view: recognizer.view!)
            
        }
    }
    func handlePan(recognizer: UIPanGestureRecognizer){
        currentS = squares[1].center
        let translation = recognizer.translation(in: motherView)
        let velocity = recognizer.velocity(in: motherView)
        
        differenceFromXOrigin = abs((originS?.x)! - currentS.x)
        differenceFromYOrigin = abs((originS?.y)! - currentS.y)
        
        switch recognizer.state {
        case .began:
            defineRotationDirection(recognizer: recognizer)
        case .ended:
            handlePanEnded(velocity: velocity, recognizer: recognizer)
        case .changed:
//            notification()
//            print("swipe limit \(swipeLimit)")
//            let wayToGo = swipeLimit - currentS.x
            
            changeRotationDirection(recognizer: recognizer)
            
        default:
            print("error")
        }
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + 0.2*translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: motherView)
    }
    func notification(type: UINotificationFeedbackGenerator.FeedbackType){
        let feedBack = UINotificationFeedbackGenerator()
        feedBack.prepare()
        if differenceFromXOrigin! > CGFloat(swipeLimit) && notified == false{
            notified = true
            //                print("vibrate at:\(differenceFromXOrigin) and notified : \(notified)")
            feedBack.notificationOccurred(type)
        }
    }
    @objc func handleSwipe(with recognizer: UISwipeGestureRecognizer) {
        //        print("swiped")
        let finalPoint = CGPoint(x:originS!.x + 1000,
                                 y:originS!.y + 50)
        
        animateCardInOut(finalPoint: finalPoint, view: recognizer.view!)
        squares[1].setAnchorPoint(CGPoint(x: 0.5,y: 0.5))
        squares[1].removeFromSuperview()
        animateReload(view: squares[0])
    }
}
enum Direction {
    case right,left
}
extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
    func getCenter() -> CGPoint {
        let x = self.frame.width/2
//        print(self.frame.width)
        let y = self.frame.height/2
        return CGPoint(x: x, y: y)
    }
}
