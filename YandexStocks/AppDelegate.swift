//
//  AppDelegate.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let stocksVC = StocksViewController()
        let navigationController = UINavigationController(rootViewController: stocksVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}
