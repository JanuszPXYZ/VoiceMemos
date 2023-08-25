//
//  OnboardingViewController.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 25/08/2023.
//

import UIKit
import AVFoundation

class OnboardingViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        containerView.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }

    private func configure() {
        scrollView.frame = containerView.bounds
        containerView.addSubview(scrollView)

        let titles = ["Welcome", "Recording"]
        for x in 0..<2 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * containerView.frame.size.width, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))

            scrollView.addSubview(pageView)

            // title, image, button
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 20, height: 120))
            let imageView = UIImageView(frame: CGRect(x: 10, y: 120+10+10, width: pageView.frame.size.width - 20, height: pageView.frame.size.height - 60 - 130 - 15))
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height - 60, width: pageView.frame.size.width - 20, height: 50))

            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica-Bold", size: 32)
            label.textColor = .white
            pageView.addSubview(label)
            label.text = titles[x]


            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "image_\(x+1)")
            pageView.addSubview(imageView)

            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 25.0
            button.setTitle("Continue", for: .normal)
            if x == 1 {
                button.setTitle("Get Started", for: .normal)
            }

            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            button.tag = x+1
            pageView.addSubview(button)
        }

        scrollView.contentSize = CGSize(width: containerView.frame.size.width*2, height: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }

    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 2 else {
            OnboardingSettings.shared.isNotANewUser()

            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                print("Permission granted")

            case .denied:
                print("Permission denied")
            case .undetermined:
                print("Request permission here")
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            default:
                print("Unknown")
            }
            return
        }

        scrollView.setContentOffset(CGPoint(x: Int(containerView.frame.size.width)*(button.tag), y: 0), animated: true)
    }

}
