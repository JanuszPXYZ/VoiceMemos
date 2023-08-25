//
//  CustomButton.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 13/08/2023.
//

import UIKit

class RecordPauseButton: UIButton {

    private(set) var imageName: String
    var buttonPressed: Bool = false

    var cornerRadius: CGFloat = 40


    init(imageName: String) {
        self.imageName = imageName
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        self.imageName = ""
        super.init(coder: coder)
        self.configure()
    }


    func configure() {
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor

        self.clipsToBounds = true
        self.contentMode = .scaleAspectFit

        let font = UIFont.systemFont(ofSize: 30)
        let config = UIImage.SymbolConfiguration(font: font)
        let image = UIImage(systemName: "recordingtape", withConfiguration: config)
        self.setImage(image, for: .normal)
        self.tintColor = UIColor.red
    }

    func recordPressed() -> Bool {
        let font = UIFont.systemFont(ofSize: 30)
        let config = UIImage.SymbolConfiguration(font: font)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)
        let originalImage = UIImage(systemName: "recordingtape", withConfiguration: config)
        buttonPressed = !buttonPressed
        if buttonPressed {
            self.tintColor = .white
        } else {
            self.tintColor = .red
        }
        buttonPressed ? self.setImage(image, for: .normal) : self.setImage(originalImage, for: .normal)

        return buttonPressed
    }


}
