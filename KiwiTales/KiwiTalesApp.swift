//
//  KiWiApp.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/5/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #unavailable(iOS 16, *) {
            FirebaseApp.configure()
        }
        
        return true
    }
}

@main
struct KiwiTalesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        if #available(iOS 16, *) {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
