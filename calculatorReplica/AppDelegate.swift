//
//  AppDelegate.swift
//  calculatorReplica
//
//  Created by Fernando Contreras González on 03/08/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //setup
        setupView()
        
        return true
    }
    
    // MARK: - Private Methods
    private func setupView(){
        
        window = UIWindow(frame: UIScreen.main.bounds)
           
        let vc = homeViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }


}

