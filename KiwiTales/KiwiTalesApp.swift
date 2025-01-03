//
//  KiWiApp.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/5/24.
//

import SwiftUI
import FirebaseCore

@main
struct KiWiTalesApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
