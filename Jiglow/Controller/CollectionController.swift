//
//  CollectionController.swift
//  Jiglow
//
//  Created by Gautier Billard on 16/01/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class CollectionController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    private let spacing:CGFloat = 10.0
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCell", for: indexPath) as! miniPallet
        
        return cell
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var navBar: UINavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "miniPallet", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        
        navBar = navigationController!.navigationBar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.applyGradient()
        navBar?.tintColor = .white
        navBar?.backItem?.title = ""
        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            print(width)
            return CGSize(width: width, height: width * 1.3)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
//MARK: - Extensions
extension UINavigationController {
    func applyGradient() {
        
        //gradient layer
        let gradient = CAGradientLayer()
        let bounds = self.navigationBar.bounds
        gradient.frame = bounds
        gradient.colors = [UIColor.orange.cgColor, UIColor.systemOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        // graident image
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradient.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradient.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        
        //applying
        let img = gradientImage
        self.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
    }
}
