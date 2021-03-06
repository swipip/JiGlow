import UIKit
import CoreData

protocol CollectionControllerDelegate {
    func collectionControllerDidDisapearWithSeletion(topColor: String, secondColor: String, thirdColor: String, bottomColor: String, editingMode: Bool, palletName: String)
    func collectionControllerDidDisapearWithNoSelection(editingMode: Bool)
    func collectionViewAnimatePallet()
    func photoVCDidDisapearFromCollectionVC(color: UIColor, option: String)
}

class CollectionController: UIViewController,UICollectionViewDataSource {
    
    //MARK: - Variables
    
    private let spacing:CGFloat = 10.0
    var miniPalletsCD = [MiniPalletModel]()
    var miniPallet: MiniPalletModel?
    var delegate: CollectionControllerDelegate?
    private var navBar: CustomNavBar!
    private var titleBar: TitleBar!
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var action = UIAlertAction()
    private var collectionView: UICollectionView!
    private var screenAdjustment: CGFloat = 0.0
    var k = K()

    //MARK: - Loading functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        k.isFrench()
        
        screenAdjustment = k.checkScreenSize(view: self.view) < 2 ? 10.0 : 0.0
        
        navBar = CustomNavBar(frame: CGRect(x: -1, y: self.view.frame.height, width:  self.view.frame.width + 2, height:  90),
                              buttonTitles: ["Photo","Main","Stack"],
                              images: [UIImage(systemName: "camera.fill")!,UIImage(systemName: "slider.horizontal.3")!,UIImage(systemName: "rectangle.stack.fill")!])
        self.view.addSubview(navBar)
        navBar.delegate = self
        
        titleBar = TitleBar(frame: CGRect(x: 0, y: 0 - screenAdjustment, width: self.view.frame.size.width, height: 90))
        self.view.addSubview(titleBar)
        
        addCollectionView()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "miniPallet", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.navBar.frame.origin.y -= 89 - self.screenAdjustment
            self.collectionView.alpha = 1.0
        }, completion: nil)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {

        if miniPalletsCD.count == 0 {
//            delegate?.collectionViewAnimatePallet()
        }
        
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
        let alert = UIAlertController(title: self.k.renamePalletMessage, message: "", preferredStyle: .alert)
        action = UIAlertAction(title: k.rename, style: .default) { (action) in
            if let name = textField.text {
                self.update(newName: name)
                self.collectionView.reloadData()
            }
        }
        alert.addAction(action)
        action.isEnabled = true
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = self.k.renamePalletPlaceHolder
        }
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Collection View
    func addCollectionView() {
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.alpha = 0
        
        self.view.insertSubview(collectionView, at: 0)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: titleBar.bottomAnchor, constant: 0),
                                     collectionView.bottomAnchor.constraint(equalTo: navBar.topAnchor, constant: 0),
                                     collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                                     collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)])
        
    }
    //MARK: - Add hint
    func saveHint() {
        
        let saveHintView = UIButton()
        
        saveHintView.backgroundColor = .gray
        saveHintView.tintColor = .white
        saveHintView.setTitle(k.addNewPalletHelper, for: .normal)
        saveHintView.alpha = 0
        
        
        self.view.addSubview(saveHintView)
        
        let saveHintViewHeight:CGFloat = 40
        saveHintView.layer.cornerRadius = saveHintViewHeight/2
        saveHintView.layer.shadowOffset = CGSize(width: 0, height:  0)
        saveHintView.layer.shadowRadius =  3.23
        saveHintView.layer.shadowOpacity = 0.23
        saveHintView.titleLabel?.textAlignment = .center
        saveHintView.titleLabel?.font = UIFont(name: "system", size: 11)
        
        
        saveHintView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([saveHintView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 130),
                                     saveHintView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                     saveHintView.heightAnchor.constraint(equalToConstant: saveHintViewHeight),
                                     saveHintView.widthAnchor.constraint(equalToConstant: 270)])
        
        saveHintView.titleLabel?.lineBreakMode = .byWordWrapping

        saveHintView.addTarget(self, action: #selector(hintPressed(_:)), for: .touchUpInside)
        
        //add return Button
        
        let returnButton = UIButton()
        returnButton.backgroundColor = .gray
        returnButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        returnButton.layer.cornerRadius = saveHintViewHeight/2
        returnButton.alpha = 0.0
        returnButton.tintColor = .white
        returnButton.layer.shadowOffset = CGSize(width: 0, height:  0)
        returnButton.layer.shadowRadius =  3.23
        returnButton.layer.shadowOpacity = 0.23
        
        self.view.addSubview(returnButton)
        
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([returnButton.topAnchor.constraint(equalTo: saveHintView.bottomAnchor, constant: 15),
                                     returnButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                                     returnButton.heightAnchor.constraint(equalToConstant: saveHintViewHeight),
                                     returnButton.widthAnchor.constraint(equalToConstant: saveHintViewHeight)])
        
        returnButton.addTarget(self, action: #selector(hintPressed(_:)), for: .touchUpInside)
        
        UIView.animate(withDuration: 0.8, animations: {
            saveHintView.alpha = 1.0
            returnButton.alpha = 1.0
        }, completion: nil)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.duration = 0.2
            animation.autoreverses = true
            animation.toValue = CGPoint(x: 1.05, y: 1.05)
            
            saveHintView.layer.add(animation, forKey: nil)
        }
        
    }
    @IBAction func hintPressed( _ sender: UIButton){
        delegate?.collectionViewAnimatePallet()
        self.navigationController?.popToRootViewController(animated: true)
    }

    //MARK: - Delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loadMiniPallets()
        
        let numberOfCells = miniPalletsCD.count
        
        if numberOfCells == 0 {
            saveHint()
        }
        return numberOfCells
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
        cell.layer.shadowRadius = 4.1536
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
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
        animateOut()
        
    }
    private func animateOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.collectionView.alpha = 0.0
            self.navBar.frame.origin.y += 90
            self.view.layoutIfNeeded()
        }) { (ended) in
            self.navBar.frame.origin.y -= 90
            self.collectionView.alpha = 1.0
            self.navigationController?.popToRootViewController(animated: false)
        }
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
            let rename = UIAction(title: self.k.rename, image: UIImage(systemName: "pencil.circle")) { action in
                self.miniPallet = self.miniPalletsCD[indexPath.row]
                self.displayAlert()
            }
            let confYes = UIAction(title: self.k.yes, image: UIImage(systemName: "trash")){ action in
                let selectedPalletFromContext = self.miniPalletsCD[indexPath.row]
                self.delete(name: (selectedPalletFromContext.name)!)
                self.collectionView.deleteItems(at: [indexPath])
            }
            let confNo = UIAction(title: self.k.no, image: UIImage(systemName: "checkmark.circle")){ action in
                
            }
            let subMenu = UIMenu(title: self.k.delete, image: UIImage(systemName: "trash"), children: [confYes,confNo])
            
            // Create and return a UIMenu with the share action
            return UIMenu(title: "Options", children: [subMenu,rename])
        }
    }
    
}
extension CollectionController: CustomNavBarDelegate {
    func navBarButtonPressed(index: Int) {

        switch index {
        case 1:
            animateOut()
        case 0:
            guard let destinationVC = storyboard?.instantiateViewController(identifier: "PhotoViewController") as? PhotoViewController else {
                print("no VC")
                return
            }
            destinationVC.delegate = self
            
            let transition = CATransition.init()
            transition.duration = 0.45
            transition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.push //Transition you want like Push, Reveal
            transition.subtype = CATransitionSubtype.fromLeft // Direction like Left to Right, Right to Left
            transition.delegate = self
            view.window!.layer.add(transition, forKey: kCATransition)
            
            self.navigationController?.pushViewController(destinationVC, animated: true)
        default:
            break
        }
        
    }
    
    
}
extension CollectionController: CAAnimationDelegate {
    
}
extension CollectionController: PhotoViewControllerDelegte {
    func PhotoVCDidDisapear(color: UIColor, option: String) {
        delegate?.photoVCDidDisapearFromCollectionVC(color: color, option: option)
    }
    
    
}
