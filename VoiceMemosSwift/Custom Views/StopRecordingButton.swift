//
//  StopRecordingButton.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 13/08/2023.
//

import UIKit

class StopRecordingButton: UIButton {

    var cornerRadius: CGFloat = 40

    init() {
        super.init(frame: .zero)
        self.isEnabled = false
        configure()
    }

    required init?(coder: NSCoder) {
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
        let image = UIImage(systemName: "stop.fill", withConfiguration: config)
        self.setImage(image, for: .normal)
        self.tintColor = UIColor.white
    }

}
