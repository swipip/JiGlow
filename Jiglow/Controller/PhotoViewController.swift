//
//  PhotoViewController.swift
//  Jiglow
//
//  Created by Gautier Billard on 19/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import AVFoundation

protocol PhotoViewControllerDelegte {
    func PhotoVCDidDisapear(color: UIColor)
}
class PhotoViewController: UIViewController{
    
    private var k = K()
    private var session = AVCaptureSession()
    private var camera: AVCaptureDevice?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var cameraCaptureOutput: AVCapturePhotoOutput?
    private var gradientLayers = [String:CAGradientLayer]()
    //delegate
    var delegate: PhotoViewControllerDelegte?
    //UI Elements
    private var optionButton = UIButton()
    private var shotButton = UIButton()
    private var colorPreview = UIView()
    private var hexLabel = UILabel()
    private var hexLabelContainer = UIView()
    private var color = UIColor()
    private var dismissButton = UIButton()
    private var rgbLabels = [UILabel]()
    
    //UI Size Constants
    private var mainItemHeight:CGFloat = UIScreen.main.bounds.size.height * 0.25
    private var secondaryItemHeight:CGFloat = 50
    private var cornerRad: CGFloat{
        get{
            return secondaryItemHeight/2
        }
    }
    //Outlets
    @IBOutlet weak var finalImageView: UIImageView!
    //Constraints
    private var widthConstraint: NSLayoutConstraint!
    private var optionButtonWidthConstraint: NSLayoutConstraint!
    private var labelContainerHeight: NSLayoutConstraint!
    private var colorPreviewHeight: NSLayoutConstraint!
    
    //MARK: - Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        initializeCaptureSession()
        
        addSubViews()
        
        layoutViews()
        
    }
    func layoutViews(){
        self.view.layoutIfNeeded()
        
        shotButton.layer.cornerRadius = cornerRad
        dismissButton.layer.cornerRadius = dismissButton.frame.size.height/2
        applyGradientToView(color1: .yellow, color2: .systemOrange, with: hexLabelContainer, viewName: "hexLabelContainer")
        applyGradientToView(color1: .yellow, color2: .systemOrange, with: shotButton, viewName: "shotButton")
        applyGradientToView(color1: .blue, color2: .systemBlue, with: optionButton, viewName: "optionButton")
        
    }
    //MARK: - AddViews
    func revealOptionsAfterShot() {
        
        UIView.animate(withDuration: 0.74, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.colorPreviewHeight.constant = self.mainItemHeight
            self.colorPreview.layer.cornerRadius = self.cornerRad
            self.optionButton.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.hexLabelContainer.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: {(finished) in
            
        })
        
    }
    func getColorsForOptionButton() ->(first: UIColor,second: UIColor){
        
        let baseColor = color
        let firstColor = baseColor.darken(by: 0.20)!
        let secondColor = baseColor.lighten(by: 0.20)!
        return (firstColor,secondColor)
        
    }
    func applyGradientToView(color1: UIColor, color2: UIColor,with view: UIView,viewName: String){
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x:0.0,y: 0)
        gradientLayer.endPoint = CGPoint(x:1, y:0)
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = cornerRad //view.frame.size.height/2
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        gradientLayers[viewName] = gradientLayer
        
    }
    func addSubViews(){
        addPointer()
        addColorPreviewView()
        addHexLabel()
        addShotButton()
        addOptionButton()
        addDismissButton()
        addRGBLabels()
    }
    func addPointer(){
        
        let pointer = UIView()
        pointer.layer.cornerRadius = 2.5
        self.view.addSubview(pointer)
        pointer.backgroundColor = .white
        pointer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([pointer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                     pointer.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
                                     pointer.heightAnchor.constraint(equalToConstant:5),
                                     pointer.widthAnchor.constraint(equalToConstant: 5)])
        
        let target = UIView()
        target.layer.cornerRadius = 30
        self.view.addSubview(target)
        target.backgroundColor = .clear
        target.layer.borderColor = UIColor.white.cgColor
        target.layer.borderWidth = 1
        target.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([target.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                     target.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
                                     target.heightAnchor.constraint(equalToConstant:60),
                                     target.widthAnchor.constraint(equalToConstant: 60)])
        
    }
    func addRGBLabels() {
        
        var topAnchor:CGFloat = 10
        
        let spacing:CGFloat = 10
        
        for _ in 1...3 {
            let newLabel = UILabel()
            newLabel.textColor = .white
            newLabel.text = ""
            newLabel.alpha = 0
            self.view.addSubview(newLabel)
            
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newLabel.leadingAnchor.constraint(equalTo: self.colorPreview.leadingAnchor, constant: 10),
                                         newLabel.topAnchor.constraint(equalTo: self.colorPreview.topAnchor, constant: topAnchor)])
            
            topAnchor += 15 + spacing
            
            self.rgbLabels.append(newLabel)
            
        }
        

        
    }
    func addColorPreviewView() {
        
        self.view.addSubview(colorPreview)
        
        //Constraints
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([colorPreview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                                     colorPreview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
                                     colorPreview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)])
        
        
        colorPreviewHeight = NSLayoutConstraint(item: colorPreview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        
        self.view.addConstraint(colorPreviewHeight)
        
        //Gestures
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler))
        swipeDown.direction = .down
        colorPreview.addGestureRecognizer(swipeDown)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpHandler))
        swipeUp.direction = .up
        colorPreview.addGestureRecognizer(swipeUp)
        
    }

    func addHexLabel(){
        
        hexLabelContainer.alpha = 0.0
        hexLabelContainer.layer.cornerRadius = cornerRad
        self.view.insertSubview(hexLabelContainer, at: 1)
        hexLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([hexLabelContainer.heightAnchor.constraint(equalToConstant: secondaryItemHeight * 1.5),
                                     hexLabelContainer.bottomAnchor.constraint(equalTo: colorPreview.topAnchor, constant: 40),
                                     hexLabelContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                                     hexLabelContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)])
        
        //        labelContainerHeight = NSLayoutConstraint(item: hexLabelContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        
        //        self.view.addConstraint(labelContainerHeight)
        
        self.view.addSubview(hexLabel)
        hexLabel.backgroundColor = .clear
        hexLabel.textColor = .white
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([hexLabel.topAnchor.constraint(equalTo: hexLabelContainer.topAnchor,constant: 10),
                                     //                                     hexLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor, constant: 0),
            hexLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 35),
            hexLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)])
        
    }
    func addShotButton(){
        shotButton.setTitle(k.cameraShotTitle, for: .normal)
        //        shotButton.setImage(UIImage(systemName:"camera.fill"), for: .normal)
        //        shotButton.tintColor = .white
        shotButton.titleLabel?.font = UIFont(name: "System", size: 17)
        shotButton.backgroundColor = .systemGreen
        
        self.view.addSubview(shotButton)
        //Constraints
        shotButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Constraints
        NSLayoutConstraint.activate([shotButton.topAnchor.constraint(equalTo: colorPreview.bottomAnchor, constant: 5),
                                     shotButton.leadingAnchor.constraint(equalTo: colorPreview.leadingAnchor, constant: 0),
                                     shotButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        widthConstraint = NSLayoutConstraint(item: shotButton, attribute: .width, relatedBy: .equal, toItem: colorPreview, attribute: .width, multiplier: 1, constant: 0)
        
        view.addConstraints([widthConstraint])
        
        //Gesture Recognizer
        shotButton.addTarget(self, action: #selector(shotButtonPressed(sender:)), for: .touchUpInside)
        
    }
    func addOptionButton(){
        
        optionButton.backgroundColor = .clear
        optionButton.layer.cornerRadius = cornerRad
        optionButton.alpha = 0.0
        optionButton.isEnabled = false
        let config = UIImage.SymbolConfiguration(weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        optionButton.setImage(image, for: .normal)
        optionButton.contentMode = .scaleAspectFit
        optionButton.tintColor = .white
        self.view.addSubview(optionButton)
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([optionButton.trailingAnchor.constraint(equalTo: colorPreview.trailingAnchor, constant: -12),
                                     optionButton.bottomAnchor.constraint(equalTo: colorPreview.bottomAnchor, constant: -12),
                                     optionButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight),
                                     optionButton.widthAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        optionButton.addTarget(self, action: #selector(optionPressed(sender:)), for: .touchUpInside)
        
    }
    func addDismissButton() {
        
        
//        dismissButton.frame.size = CGSize(width: 50, height: 50)
        
        dismissButton.backgroundColor = .darkGray
        dismissButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.alpha = 0.6
        self.view.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
                                 dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                                 dismissButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight),
                                 dismissButton.widthAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed(sender: )), for: .touchUpInside)
        
    }
    @IBAction func dismissButtonPressed(sender: UIButton) {
        navigationController?.popToRootViewController(animated:true)
    }
    //MARK: - Actions & Gestures
    @objc func swipeUpHandler() {
        UIView.animate(withDuration: 0.567, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.12, options: .curveEaseInOut, animations: {
            self.colorPreviewHeight.constant = self.view.frame.size.height * 0.7
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    @objc func swipeDownHandler(sender: UISwipeGestureRecognizer) {
        
        let constant = colorPreviewHeight.constant

        UIView.animate(withDuration: 0.567, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.colorPreviewHeight.constant = self.mainItemHeight < constant ? self.mainItemHeight : 0.0
            self.colorPreview.layer.cornerRadius = self.mainItemHeight < constant ? self.cornerRad : 3
            self.optionButton.alpha = self.mainItemHeight < constant ? 1 : 0
            self.hexLabel.text = self.mainItemHeight < constant ? self.hexLabel.text : nil
            self.rgbLabels[0].alpha = self.mainItemHeight < constant ? 1 : 0
            self.rgbLabels[1].alpha = self.mainItemHeight < constant ? 1 : 0
            self.rgbLabels[2].alpha = self.mainItemHeight < constant ? 1 : 0
            self.view.layoutIfNeeded()
        }, completion: {(finished) in

        })

        UIView.animate(withDuration: 0.567) {
            self.hexLabelContainer.alpha = self.mainItemHeight < constant ? 1 : 0
            self.view.layoutIfNeeded()
        }
        
        optionButton.isEnabled = mainItemHeight < constant ? true : false
    }
    @IBAction func shotButtonPressed(sender: UIButton){
        takePicture()
        revealOptionsAfterShot()
        optionButton.isEnabled = true
    }
    @IBAction func optionPressed(sender: UIButton){
        delegate?.PhotoVCDidDisapear(color: self.color)
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - Camera Session
    func initializeCaptureSession(){
        session.sessionPreset = AVCaptureSession.Preset.high
        
        camera = AVCaptureDevice.default(for: .video)
        
        do{
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
            cameraCaptureOutput = AVCapturePhotoOutput()
            
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            
            
        }catch{
            print(error)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        session.startRunning()
        
    }
    func takePicture() {
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    //        func displayCapturedPhoto(photo: UIImage){
    //            let imagePreviewViewController = storyboard?.instantiateViewController(identifier: "ImagePreviewViewController") as! ImagePreviewViewController
    //            imagePreviewViewController.captureImaged = photo
    //            navigationController?.pushViewController(imagePreviewViewController, animated: true)
    //        }
    
}
//MARK: - Extensions
extension PhotoViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let finalImage = UIImage(data: imageData){
                
                finalImageView.image = finalImage
                
                color = getPixelColorAtPoint(point: CGPoint(x: self.view.frame.size.width/2,y: 200/812*finalImageView.frame.height), sourceView: self.finalImageView)
                let color1 = self.color.darken(by: 20)?.cgColor ?? UIColor.red.cgColor
                let color2 = self.color.darken(by: 10)?.cgColor ?? UIColor.red.cgColor
                let color3 = self.color.darken(by: 5)?.cgColor ?? UIColor.red.cgColor
                
                finalImageView.image = nil
                self.hexLabel.text = self.color.toHexString()
                self.updateRgbLabelsValues()
                UIView.animate(withDuration: 0.32) {
                    self.colorPreview.backgroundColor = self.color
                    self.gradientLayers["optionButton"]!.colors = [color1,color2]
                    self.gradientLayers["hexLabelContainer"]!.colors = [color1,color2]
                    self.gradientLayers["shotButton"]!.colors = [color1,color3]
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    func updateRgbLabelsValues() {
        
        let colorLabels = ["R ","G ","B "]
        
        let red = Int(color.rgb.red * 255)
        let green = Int(color.rgb.green * 255)
        let blue = Int(color.rgb.blue * 255)
        
        let values = [red, green, blue]
        
        for i in 0...2 {
            animateRgbLabels(for: i,alpha: 1.0)
            self.rgbLabels[i].text = String("\(colorLabels[i])\(values[i])")
        }
    }
    func animateRgbLabels(for i: Int,alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
             self.rgbLabels[i].alpha = 1.0
         }
    }
    func getPixelColorAtPoint(point: CGPoint, sourceView: UIView) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        sourceView.layer.render(in: context!)
        let color: UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                     green: CGFloat(pixel[1])/255.0,
                                     blue: CGFloat(pixel[2])/255.0,
                                     alpha: CGFloat(pixel[3])/255.0)
        //        pixel.deallocate()
        return color
    }
}
extension UIImage {
    func getPixelColor2(pos: CGPoint) -> UIColor {
        let cgImage : CGImage = self.cgImage!
        guard let pixelData = CGDataProvider(data: (cgImage.dataProvider?.data)!)?.data else {
            return UIColor.clear
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}
extension UIColor {
    
    func lighten(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darken(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
