//
//  CircularView.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 13/08/2023.
//

import UIKit

@IBDesignable
class CircularView: UIView {

    static let identifier = "CircularView"

    @IBInspectable var imageName: String

    @IBOutlet weak var systemImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    var imageToDisplay: UIImage = {
        var image = UIImage(systemName: "stop.fill")!
        image = image.withRenderingMode(.alwaysTemplate)
        return image
    }()

    init(frame: CGRect, imageName: String) {
        self.imageName = imageName
        super.init(frame: .zero)
    }


    required init?(coder aDecoder: NSCoder) {
        self.imageName = ""
        super.init(coder: aDecoder)
        initFromNib()
        configureView()
    }

    func configureView() {
        mainView.layer.cornerRadius = mainView.frame.width / 2
        mainView.layer.borderWidth = 2.0
        mainView.layer.borderColor = UIColor.white.cgColor
        self.systemImageView.image = UIImage(systemName: self.imageName)
        self.systemImageView.contentMode = .scaleAspectFit
        self.systemImageView.tintColor = .white

    }

    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func initFromNib() {
        let nib = UINib(nibName: Self.identifier, bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Unable to convert nib")
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]


        addSubview(view)
    }
}
