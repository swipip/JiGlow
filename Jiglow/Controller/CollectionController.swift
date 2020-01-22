import UIKit
protocol CollectionControllerDelegate {
    func viewDidDisapear(topColor: UIColor, secondColor: UIColor, thirdColor: UIColor, bottomColor: UIColor)
}

class CollectionController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    private let spacing:CGFloat = 2.0
    
    var miniPallets = [MiniPallet]()
    
    var miniPallet: MiniPallet?
    
    var delegate: CollectionControllerDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var navBar: UINavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "miniPallet", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        
        navBar = navigationController!.navigationBar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navBar?.backItem?.title = ""
        navBar?.tintColor = .black
//        navBar?.backItem?.action
//        navigationController?.applyGradient(color1: .lightGray, color2: .gray)
//        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
//        collectionView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        if let safeMiniPallet = miniPallet{
            delegate?.viewDidDisapear(topColor: safeMiniPallet.topTileColor!, secondColor: safeMiniPallet.secondTileColor!, thirdColor: safeMiniPallet.thirdTileColor!, bottomColor: safeMiniPallet.bottomTileColor!)
        }
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? ViewController{
//            print("go back")
//        }
//    }
    
    //MARK: - Delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(miniPallets.count)
        return miniPallets.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCell", for: indexPath) as! MiniPallet
        
        cell.updateColor(top: miniPallets[indexPath.row].topTileColor!, second: miniPallets[indexPath.row].secondTileColor!, third: miniPallets[indexPath.row].thirdTileColor!, bottom: miniPallets[indexPath.row].bottomTileColor!)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 10
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            print(width)
            return CGSize(width: width, height: width * 1.21)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        
        miniPallet = miniPallets[indexPath.row]
        
        UIView.animate(withDuration: 0.1, animations: {
            collectionView.cellForItem(at: indexPath)!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: nil)
        
        navigationController?.popViewController(animated: true)
        
    }
    

}
//MARK: - Extensions
extension UINavigationController {
    func applyGradient(color1: UIColor, color2: UIColor) {
        
        //gradient layer
        let gradient = CAGradientLayer()
        let bounds = self.navigationBar.bounds
        gradient.frame = bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
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
