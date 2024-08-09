//
//  AppDelegate.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 8/8/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        window?.makeKeyAndVisible()
        navigationController = UINavigationController(rootViewController: MainViewController())
        window?.rootViewController = navigationController
        return true
    }

}

