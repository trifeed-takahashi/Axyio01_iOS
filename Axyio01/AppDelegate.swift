//
//  AppDelegate.swift
//  Axyio01
//
//  Created by 高橋聖二 on 2017/11/13.
//  Copyright © 2017年 trifeed inc. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 通知を許可してもらうダイアログを出す
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(granted, error) in
            if granted {
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
            }
        })
        
        return true
    }

    // リモート通知のデバイストークン取得成功
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        let tokenString = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        successGetDeviceToken(deviceToken: tokenString)
    }
    
    // リモート通知のデバイストークン取得の失敗・・・どうしよ？
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error){
        print("Failed to get deviceToken, error: \(error.localizedDescription)")
        successGetDeviceToken(deviceToken: "")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func successGetDeviceToken( deviceToken: String) -> Void {
        print("deviceToken = \(deviceToken)")
        let push_host : String = NSLocalizedString("push_host", comment: "");
        let push_url : String = NSLocalizedString("push_url_registtoken", comment: "");
        print("Push host = \(push_host)")
        print("Push url = \(push_url)")
        let request_url = "http://\(push_host)\(push_url)"
        print(request_url);
    }

}

