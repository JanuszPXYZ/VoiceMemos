//
//  OnboardingSettings.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 25/08/2023.
//

import Foundation

final class OnboardingSettings {
    static let shared = OnboardingSettings()

    func firstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isFirstLaunch")
    }

    func isNotANewUser() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
    }
}
