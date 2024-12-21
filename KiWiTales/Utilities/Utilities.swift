//
//  Utilities.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import Foundation
import UIKit

final class Utilities {
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func rootViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return rootViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return rootViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return rootViewController(controller: presented)
        }
        
        return controller
    }
}
