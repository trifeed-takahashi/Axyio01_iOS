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
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            
            if granted {
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
                debugPrint("通知許可")
            } else {
                debugPrint("通知拒否")
            }
        })
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        
        // ここで拡張ペイロードが取得出来た。メッセージと一緒に取得出来る方法…？
        print(userInfo);
        
        completionHandler(UIBackgroundFetchResult.newData)
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
        #if DEBUG
            NSLog("applicationWillEnterForeground")
        #endif
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // デバイストークンをサーバへ登録する
    private func successGetDeviceToken( deviceToken: String) -> Void {

        let push_host : String = NSLocalizedString("push_host", comment: "");
        let push_url : String = NSLocalizedString("push_url_registtoken", comment: "");
        let request_url = "https://\(push_host)\(push_url)"

        print("deviceToken = \(deviceToken)")
        print("Push host = \(push_host)")
        print("Push url = \(push_url)")
        print(request_url);
        
        // サーバへリクエストを行う
        let parameters = [
            "project": "axyio01",
            "devicetoken": deviceToken
        ]
        Alamofire.request(request_url, method: HTTPMethod.post, parameters: parameters).responseString { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if notification.request.trigger is UNPushNotificationTrigger {
            debugPrint("プッシュ通知受信")
        }
        print("========================================================")
        //print("Push Notification will present \(notification)")
        //print(notification.request.identifier)
        //print(notification.request.content.userInfo)
        let userinfokeys = notification.request.content.userInfo.keys
        print(userinfokeys)
        let alert_id = notification.request.content.userInfo["alert_id"]
        if(alert_id != nil){
            print(alert_id!)
        }
        print("========================================================")
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        debugPrint(response.notification.request.identifier)
        
        
        //print(response.notification.request.identifier)
        //print(response.notification.request.content.userInfo)
        let userinfokeys = response.notification.request.content.userInfo.keys
        print(userinfokeys)

        let alert_id: Any? = response.notification.request.content.userInfo["alert_id"]
        if(alert_id != nil){
            print(alert_id!)
        }
        
        // その他のタイプの通知に関するアクションをハンドル。
        //print("Push Notification did receive \(response)")
        completionHandler()
    }
}

