import UIKit
import CoreData

protocol CollectionControllerDelegate {
    func viewDidDisapear(topColor: String, secondColor: String, thirdColor: String, bottomColor: String)
}

class CollectionController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    //MARK: - Variables
    
    private let spacing:CGFloat = 2.0
    var miniPalletsCD = [MiniPalletModel]()
    var miniPallet: MiniPalletModel?
    var delegate: CollectionControllerDelegate?
    var navBar: UINavigationBar?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var collectionView: UICollectionView!

    //MARK: - Loading functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMiniPallets()
        
        print(miniPalletsCD)
        
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
            delegate?.viewDidDisapear(topColor: safeMiniPallet.topColor!,
                                      secondColor: safeMiniPallet.secondColor!,
                                      thirdColor: safeMiniPallet.thirdColor!,
                                      bottomColor: safeMiniPallet.bottomColor!)
        }
        
    }
    

    //MARK: - Delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return miniPalletsCD.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCell", for: indexPath) as! MiniPallet
        
        cell.updateColorCD(top: miniPalletsCD[indexPath.row].topColor!,
                           second:  miniPalletsCD[indexPath.row].secondColor!,
                           third:  miniPalletsCD[indexPath.row].thirdColor!,
                           bottom: miniPalletsCD[indexPath.row].bottomColor!)
        
        cell.palletNameLabel.text = miniPalletsCD[indexPath.row].name ?? "no name"
        
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
        
        miniPallet = miniPalletsCD[indexPath.row]
        navigationController?.popViewController(animated: true)
        
    }
    //MARK: - Data Management
    func loadMiniPallets() {
        let request : NSFetchRequest<MiniPalletModel> = MiniPalletModel.fetchRequest()
        
        do{
            miniPalletsCD = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
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
