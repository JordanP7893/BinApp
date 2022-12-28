//
//  ErrorAlertController.swift
//  BinApp
//
//  Created by Jordan Porter on 06/06/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UIKit

class ErrorAlertController {
    
    func showErrorAlertView(in parentViewController: UIViewController, with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(okayAction)
        parentViewController.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlertInTopViewController(withTitle title: String, and message: String) {
        DispatchQueue.main.async {
            guard let topViewController = self.topMostController() else { return }
            
            self.showErrorAlertView(in: topViewController, with: title, and: message)
        }
    }
    
    private func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
    
}
