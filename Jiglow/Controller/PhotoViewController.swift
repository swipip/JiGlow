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
    private var addButton = UIButton()
    private var shotButton = UIButton()
    private var colorPreview = UIView()
    private var hexLabel = UILabel()
    private var hexLabelContainer = UIView()
    private var color = UIColor()
    private var dismissButton = UIButton()
    private var rgbLabels = [UILabel]()
    private var infoButton = UIButton()
    private var gauges = [UIView]()
    private var gaugesBacks = [UIView]()
    private var gaugesLabels = [UILabel]()
    private var gaugesMiniWidth:CGFloat  = 0.0
    private var gaugesWidth:CGFloat = 0.0{
        willSet {
            gaugesMiniWidth = 0.3 * newValue
        }
    }
    private var gaugesConstraints = [NSLayoutConstraint]()
    
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
    private var buttonTrailling: NSLayoutConstraint!
    //    private var widthConstraint: NSLayoutConstraint!
    private var addButtonLeading: NSLayoutConstraint!
    private var labelContainerHeight: NSLayoutConstraint!
    private var colorPreviewHeight: NSLayoutConstraint!
    
    //MARK: - Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        gaugesWidth = 100
        
        initializeCaptureSession()
        
        addSubViews()
        
        layoutViews()
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gradientLayers["shotButton"]?.frame = shotButton.bounds
        
    }
    func layoutViews(){
        self.view.layoutIfNeeded()
        
        shotButton.layer.cornerRadius = cornerRad
        dismissButton.layer.cornerRadius = dismissButton.frame.size.height/2
        applyGradientToView(color1: .yellow, color2: .systemOrange, with: shotButton, viewName: "shotButton")
        
    }
    //MARK: - AddViews
    func revealOptionsAfterShot() {
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.buttonTrailling.constant = -147
            self.addButtonLeading.constant = 10
            self.addButton.alpha = 0.6
            self.colorPreviewHeight.constant = self.mainItemHeight
            self.colorPreview.layer.cornerRadius = self.cornerRad
            self.colorPreview.alpha = 1.0
            self.infoButton.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: {(ended) in
            self.highlightInfoButton()
        })
        
    }
    func getColorsForOptionButton() ->(first: UIColor,second: UIColor){
        
        let baseColor = color
        let firstColor = baseColor.darken(by: 0.20)!
        let secondColor = baseColor.lighten(by: 0.20)!
        return (firstColor,secondColor)
        
    }
    func applyGradientToView(color1: UIColor, color2: UIColor,with view: UIView,viewName: String){
        
        if gradientLayers[viewName] == nil {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [color1.cgColor, color2.cgColor]
            gradientLayer.startPoint = CGPoint(x:0.0,y: 1)
            gradientLayer.endPoint = CGPoint(x:1, y:0)
            gradientLayer.frame = view.bounds
            gradientLayer.cornerRadius = cornerRad //view.frame.size.height/2
            view.layer.insertSublayer(gradientLayer, at: 0)
            
            gradientLayers[viewName] = gradientLayer
        }else{
            //           gradientLayers[viewName]?.removeFromSuperlayer()
        }
    }
    func addSubViews(){
        addPointer()
        addShotButton()
        addColorPreviewView()
        addHexLabel()
        addOptionButton()
        addDismissButton()
        addInfoButton()
        addGauges()
        //        addRGBLabels()
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
        
        colorPreview.alpha = 0.0
        self.view.addSubview(colorPreview)
        
        //Constraints
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([colorPreview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                     colorPreview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                                     colorPreview.bottomAnchor.constraint(equalTo: shotButton.topAnchor, constant: -10)])
        
        
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
    //MARK: - HexLabel
    func addHexLabel(){
        
        self.colorPreview.addSubview(hexLabel)
        hexLabel.backgroundColor = .clear
        hexLabel.textColor = .clear
        hexLabel.text = "#123456"
        hexLabel.font = UIFont.systemFont(ofSize: 30)
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hexLabel.leadingAnchor.constraint(equalTo: self.colorPreview.leadingAnchor, constant: 15),
            hexLabel.bottomAnchor.constraint(equalTo: self.colorPreview.bottomAnchor, constant: -15)])
        
    }
    //MARK: - ShotButton
    func addShotButton(){
        //        shotButton.setTitle(k.cameraShotTitle, for: .normal)
        shotButton.setImage(UIImage(systemName:"camera.fill"), for: .normal)
        shotButton.tintColor = .white
        shotButton.backgroundColor = .clear
        shotButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        shotButton.backgroundColor = .systemGreen
        
        self.view.addSubview(shotButton)
        //Constraints
        shotButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Constraints
        NSLayoutConstraint.activate([shotButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -45),
                                     shotButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                     shotButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        buttonTrailling = NSLayoutConstraint(item: shotButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -20)
        
        view.addConstraints([buttonTrailling])
        
        //Gesture Recognizer
        shotButton.addTarget(self, action: #selector(shotButtonPressed(sender:)), for: .touchUpInside)
        
    }
    @IBAction func shotButtonPressed(sender: UIButton){
        takePicture()
        revealOptionsAfterShot()
        //        optionButton.isEnabled = true
        
    }
    //MARK: - add Button
    func addOptionButton(){
        
        addButton.backgroundColor = .darkGray
        addButton.alpha = 0.6
        addButton.layer.cornerRadius = cornerRad
        addButton.alpha = 0.0
        addButton.isEnabled = true
        addButton.tintColor = .white
        addButton.setTitle(" Ajouter", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        //        let config = UIImage.SymbolConfiguration(weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: nil)
        addButton.setImage(image, for: .normal)
        //        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        addButton.contentMode = .scaleAspectFit
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: shotButton.bottomAnchor, constant: 0),
            addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addButton.topAnchor.constraint(equalTo: shotButton.topAnchor, constant: 0)])
        
        addButtonLeading = NSLayoutConstraint(item: addButton, attribute: .leading, relatedBy: .equal, toItem: shotButton, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.view.addConstraints([addButtonLeading])
        
        addButton.addTarget(self, action: #selector(optionPressed(sender:)), for: .touchUpInside)
        
    }
    @IBAction func optionPressed(sender: UIButton){
        delegate?.PhotoVCDidDisapear(color: self.color)
        self.navigationController?.popToRootViewController(animated: true)
    }
    //MARK: - Info Button
    func addInfoButton() {
        
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.tintColor = .white
        infoButton.alpha = 0.0
        
        self.view.addSubview(infoButton)
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: hexLabel.centerYAnchor, constant: 0),
            infoButton.trailingAnchor.constraint(equalTo: colorPreview.trailingAnchor, constant: -10),
            infoButton.widthAnchor.constraint(equalToConstant: secondaryItemHeight),
            infoButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(infoPressed(_:)))
        longPress.minimumPressDuration = 0.0
        infoButton.addGestureRecognizer(longPress)
        
    }
    func highlightInfoButton(factor: CGFloat? = 1.0) {
        
        var delayForAnimation = 0.0
        
        for _ in 1...2 {
            
            let circle = UIView()
            
            circle.transform = CGAffineTransform(scaleX: factor!, y: factor!)
            circle.backgroundColor = .clear
            circle.layer.borderColor = UIColor.white.cgColor
            circle.layer.borderWidth = 0.2
            circle.layer.cornerRadius = 10
            self.infoButton.insertSubview(circle, at: 0)
            
            circle.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([circle.centerYAnchor.constraint(equalTo: self.infoButton.centerYAnchor, constant: 0),
                                         circle.centerXAnchor.constraint(equalTo: self.infoButton.centerXAnchor, constant: 0),
                                         circle.widthAnchor.constraint(equalToConstant: 20),
                                         circle.heightAnchor.constraint(equalToConstant: 20)])
            
            UIView.animate(withDuration: 1.0, delay: delayForAnimation, options: .curveEaseOut, animations: {
                circle.transform = CGAffineTransform(scaleX: 5, y: 5)
                circle.alpha = 0.0
            }, completion: nil)
            
            delayForAnimation += 0.2
            
        }
        
    }
    @objc func infoPressed(_ recognizer: UILongPressGestureRecognizer) {
        
        func animateButton(toState: gaugesState){
            
            let toScale:CGFloat = toState == .on ? 1.2 : 1
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.12, options: .curveEaseInOut, animations: {
                self.infoButton.transform = CGAffineTransform(scaleX: toScale, y: toScale)
            }, completion: {(ended) in
                if toState == .on {
                    self.highlightInfoButton(factor: 1.2)
                }
            })
        }
        
        let color = colorPreview.backgroundColor
        if let color = color {
            
            let red = Double(color.rgb.red)
            let green = Double(color.rgb.green)
            let blue = Double(color.rgb.blue)
            
            switch recognizer.state {
            case .began:
                animateButton(toState: .on)
                animateGaugesOnOff(red: red, green: green, blue: blue, toState: .on)
            case .ended:
                animateButton(toState: .off)
                animateGaugesOnOff(red: red, green: green, blue: blue, toState: .off)
            default:
                break
            }
        }

    }
    //MARK: - Dismiss Button
    func addDismissButton() {
        
        dismissButton.backgroundColor = .darkGray
        dismissButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.alpha = 0.6
        self.view.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
                                     dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                     dismissButton.heightAnchor.constraint(equalToConstant: secondaryItemHeight),
                                     dismissButton.widthAnchor.constraint(equalToConstant: secondaryItemHeight)])
        
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed(sender: )), for: .touchUpInside)
        
    }
    @IBAction func dismissButtonPressed(sender: UIButton) {
        navigationController?.popToRootViewController(animated:true)
    }
    //MARK: - Gauges
    func addGauges() {
        
        let indentHeight:CGFloat = 8
        var compoundedHeight:CGFloat = indentHeight
        
        let gaugesHeight = gaugesMiniWidth//(100-2*compoundedHeight)/3
        let colors = [UIColor.systemBlue, UIColor.systemGreen, UIColor.systemRed]
        var delayForAnimation = 0.2
        let gaugesWidth = self.gaugesWidth + gaugesMiniWidth
        
        for i in 0...2 {
            let newGaugeBack = UIView()
            newGaugeBack.backgroundColor = .lightGray
            newGaugeBack.layer.cornerRadius = gaugesHeight/2
            newGaugeBack.alpha = 0.0
            
            self.view.addSubview(newGaugeBack)
            
            newGaugeBack.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([newGaugeBack.bottomAnchor.constraint(equalTo: self.colorPreview.topAnchor, constant: -compoundedHeight),
                                         newGaugeBack.widthAnchor.constraint(equalToConstant: gaugesWidth),
                                         newGaugeBack.heightAnchor.constraint(equalToConstant: gaugesHeight),
                                         newGaugeBack.leadingAnchor.constraint(equalTo: colorPreview.leadingAnchor, constant: 0)])
            
            
            
            //gauges
            
            let newGauge = UIView()
            newGauge.backgroundColor = colors[i]
            newGauge.alpha = 0.0
            newGauge.layer.cornerRadius = gaugesHeight/2
            newGauge.layer.shadowRadius = 2
            newGauge.layer.shadowOpacity = 0.2
            newGauge.layer.shadowOffset = CGSize(width: 0.2, height: 0)
            
            self.view.addSubview(newGauge)
            
            newGauge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newGauge.leadingAnchor.constraint(equalTo: colorPreview.leadingAnchor, constant: 0),
                                         newGauge.bottomAnchor.constraint(equalTo: colorPreview.topAnchor, constant: -compoundedHeight),
                                         newGauge.heightAnchor.constraint(equalToConstant: gaugesHeight)])
            
            let constraint = NSLayoutConstraint(item: newGauge, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: gaugesMiniWidth )
            
            gaugesConstraints.append(constraint)
            self.view.addConstraint(constraint)
            
            
            gaugesBacks.append(newGaugeBack)
            gauges.append(newGauge)
            
            
            compoundedHeight += gaugesHeight + indentHeight
            
            newGaugeBack.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            
            UIView.animate(withDuration: 0.3, delay: delayForAnimation, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.12, options: .curveEaseOut, animations: {
                newGaugeBack.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (ended) in
                
            }
            delayForAnimation += 0.1
            
            let newLabel = UILabel()
            newLabel.text = "0"
            newLabel.font = UIFont.systemFont(ofSize: 10)
            
            
            newLabel.textColor = .white
            
            newGauge.addSubview(newLabel)
            
            gaugesLabels.append(newLabel)
            
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newLabel.trailingAnchor.constraint(equalTo: newGauge.trailingAnchor, constant: -8),
                                         newLabel.centerYAnchor.constraint(equalTo: newGauge.centerYAnchor, constant: 0)])
        }
    }
    private enum gaugesState {
        case on, off
    }

    private func animateGaugesOnOff(red: Double,green: Double, blue: Double, toState: gaugesState) {
        
        let widths = [blue,green,red]
        
        func animateGauges(toState: gaugesState, for i: Int) {
            
            let width:CGFloat = toState == .on ? CGFloat(widths[i] * Double(gaugesWidth)) : gaugesMiniWidth
            let toAlpha:CGFloat = toState == .on ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.2) {
                self.gauges[i].alpha = toAlpha
                self.gaugesBacks[i].alpha = toAlpha * 0.6
            }
            
            UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.gaugesConstraints[i].constant = width + self.gaugesMiniWidth
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        for i in 0...2 {
            
            animateGauges(toState: toState, for: i)
            
            let target = min(255,widths[i] * 255)
            let indent:Double = (target) * 1/60
            var number:Double = 0.0
            
            let _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
                number += indent
                if number >= target {
                    self.gaugesLabels[i].text = String(Int(target))
                    timer.invalidate()
                }else{
                    self.gaugesLabels[i].text = String(Int(number))
                }
            }
        }

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
            self.addButton.alpha = self.mainItemHeight < constant ? 0.6 : 0
            self.infoButton.alpha = self.mainItemHeight < constant ? 1 : 0
            self.hexLabel.text = self.mainItemHeight < constant ? self.hexLabel.text : nil
            self.buttonTrailling.constant = self.mainItemHeight < constant ? -147 : -20
            self.view.layoutIfNeeded()
        }, completion: {(finished) in
            
        })
        
        UIView.animate(withDuration: 0.567) {
            self.hexLabelContainer.alpha = self.mainItemHeight < constant ? 1 : 0
            self.view.layoutIfNeeded()
        }
        
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
                let color1 = self.color
                let color2 = self.color.withHueOffset(offset: 1/12)
                
                finalImageView.image = nil
                self.hexLabel.text = self.color.toHexString()
                UIView.animate(withDuration: 0.32) {
                    self.colorPreview.backgroundColor = self.color
                    self.gradientLayers["shotButton"]!.colors = [color1.cgColor,color2.cgColor]
                    self.hexLabel.adjustTextColor(color: self.color)
                    self.infoButton.adjustTextColor(color: self.color)
                    self.view.layoutIfNeeded()
                }
            }
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

