import UIKit

class TitleBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commonInit() {
        setBar()
    }
    private func setBar() {
        
        let bar = UIView(frame: frame)
        bar.applyGradient()
        bar.roundCorners([.bottomLeft,.bottomRight], radius: 12)
        bar.applyGradient()
        addSubview(bar)
        
        let title = UILabel()
        title.text = "Jiglow"
        title.font = UIFont(name: "Lobster", size: 20)
        title.textColor = .white
        
        addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([title.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),])
        
        
    }

}
