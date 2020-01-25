//
//  PhotoViewController.swift
//  Jiglow
//
//  Created by Gautier Billard on 19/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            present(vc,animated: true)
        
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
//        guard let image = info[.editedImage] as? UIImage else{
//            return
//        }
        
//        print(vc)
        
    }


}
extension CALayer {

func colorOfPoint(point:CGPoint) -> CGColor {

    var pixel: [CUnsignedChar] = [0, 0, 0, 0]

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

    context!.translateBy(x: -point.x, y: -point.y)

    self.render(in: context!)

    let red: CGFloat   = CGFloat(pixel[0]) / 255.0
    let green: CGFloat = CGFloat(pixel[1]) / 255.0
    let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
    let alpha: CGFloat = CGFloat(pixel[3]) / 255.0

    let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)

    return color.cgColor
    
    }
}
