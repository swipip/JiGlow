import UIKit
import CoreData

protocol CollectionControllerDelegate {
    func collectionControllerDidDisapearWithSeletion(topColor: String, secondColor: String, thirdColor: String, bottomColor: String, editingMode: Bool, palletName: String)
    func collectionControllerDidDisapearWithNoSelection(editingMode: Bool)
}

class CollectionController: UIViewController,UICollectionViewDataSource {
    
    //MARK: - Variables
    
    private let spacing:CGFloat = 10.0
    var miniPalletsCD = [MiniPalletModel]()
    var miniPallet: MiniPalletModel?
    var delegate: CollectionControllerDelegate?
    var navBar: UINavigationBar?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var action = UIAlertAction()
    @IBOutlet weak var collectionView: UICollectionView!

    //MARK: - Loading functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadMiniPallets()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "miniPallet", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        
        navBar = navigationController!.navigationBar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navBar?.backItem?.title = ""
        navBar?.tintColor = .label
//        navBar?.backItem?.action
//        navigationController?.applyGradient(color1: .lightGray, color2: .gray)
//        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
    }
    override func viewWillDisappear(_ animated: Bool) {

        if let safeMiniPallet = miniPallet{
            delegate?.collectionControllerDidDisapearWithSeletion(topColor: safeMiniPallet.topColor!,
                                      secondColor: safeMiniPallet.secondColor!,
                                      thirdColor: safeMiniPallet.thirdColor!,
                                      bottomColor: safeMiniPallet.bottomColor!,
                                      editingMode: true,
                                      palletName: safeMiniPallet.name!)
        }else{
            delegate?.collectionControllerDidDisapearWithNoSelection(editingMode: false)
        }
    }
    func displayAlert() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Rename your pallet", message: "", preferredStyle: .alert)
        action = UIAlertAction(title: "Rename", style: .default) { (action) in
            if let name = textField.text {
                self.update(newName: name)
                self.collectionView.reloadData()
            }
        }
        alert.addAction(action)
        action.isEnabled = true
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Your pallet's name"
        }
        present(alert, animated: true, completion: nil)
    }
    

    //MARK: - Delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loadMiniPallets()
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
        
        cell.backgroundColor = .clear
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 6.1536
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.cornerView.layer.cornerRadius).cgPath
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 10
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow

            return CGSize(width: width, height: width * 1.21)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    func delete(name: String) {
        
        let request: NSFetchRequest<MiniPalletModel> = MiniPalletModel.fetchRequest()
        let predicate = NSPredicate(format: "name MATCHES[cd] %@", name)
        request.predicate = predicate
        do{
            miniPalletsCD = try context.fetch(request)
            context.delete(miniPalletsCD[0])
            try context.save()
        }catch{
            print("Error retrieving data")
        }
    }
    func update(newName: String){
        miniPallet?.setValue(newName, forKey: "name")
        do{
            try context.save()
        }catch{
            
        }
    }
}
//MARK: - Extensions
extension CollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (Actions) -> UIMenu? in
            let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil.circle")) { action in
                self.miniPallet = self.miniPalletsCD[indexPath.row]
                self.displayAlert()
            }
            let confYes = UIAction(title: "Yes", image: UIImage(systemName: "trash")){ action in
                let selectedPalletFromContext = self.miniPalletsCD[indexPath.row]
                self.delete(name: (selectedPalletFromContext.name)!)
                self.collectionView.deleteItems(at: [indexPath])
            }
            let confNo = UIAction(title: "No", image: UIImage(systemName: "checkmark.circle")){ action in
                
            }
            let subMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), children: [confYes,confNo])
                   
            // Create and return a UIMenu with the share action
            return UIMenu(title: "Options", children: [subMenu,rename])
        }
    }

}

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
