import UIKit

class SliderCallout: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var calloutLabel: ColorLabel!
    @IBOutlet weak var calloutBubble: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("SliderCallOut", owner: self, options: nil)
        addSubview(contentView)
        contentView.isUserInteractionEnabled = true
        contentView.frame = self.bounds
    }
}
