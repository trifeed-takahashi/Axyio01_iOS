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

struct ParseError: Error {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var myDeviceToken: String = ""
    let push_host : String = NSLocalizedString("push_host", comment: "")
    var view_recentMessage = ""
    var view_isconfirm = false
    var viewController: ViewController!
    var alert_id = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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

        let push_url : String = NSLocalizedString("push_url_registtoken", comment: "")
        let request_url = "https://\(push_host)\(push_url)"
        self.myDeviceToken = deviceToken;

        print("deviceToken = \(deviceToken)")
        print("Push host = \(push_host)")
        print("Push url = \(push_url)")
        print(request_url);
        
        // サーバへリクエストを行う
        let parameters = [
            "project": "axyio01",
            "devicetoken": deviceToken
        ]
        Alamofire.request(request_url, method: .post, parameters: parameters).responseString { response in
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

    private func parseJson(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw ParseError()
        }
        let json = try JSONSerialization.jsonObject(with: data)
        guard let rows = json as? [[String:Any]] else {
            throw ParseError()
        }
        for row in rows {
            let result = row["result"] ?? ""
            let message = row["message"] ?? ""
            print("\(result) : \(message)")
        }
    }

    
    // サーバから警報メッセージを取得する
    private func getMessageFromServer(alert_id: String) -> Void {

        let push_url : String = NSLocalizedString("get_alert_message", comment: "")
        let request_url = "https://\(push_host)\(push_url)"
        var ret_message = ""
        
        // サーバへリクエストを行う
        let parameters = [
            "project": "axyio01",
            "alert_id": alert_id
        ]
        
        Alamofire.request(request_url, method: .post, parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result

            if response.result.isSuccess {
                if let dict = response.result.value as? NSDictionary {
                    if dict["message"] != nil {
                        ret_message = dict["message"] as! String
                        print(ret_message)
                        self.view_recentMessage = ret_message;
                        self.view_isconfirm = false;

                        // TODO: viewのリロードを行う
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.viewController.reloadView(msg: self.view_recentMessage, mytoken: self.myDeviceToken, alert_id: alert_id)
                    }
                }
            }else{
                print(response.error.debugDescription)
            }
        }
    }

    private func getAlertMessage(userinfo info : [AnyHashable:Any]) -> Void {

        var alert_id_str = ""
        let alert_id_op: Any? = info["alert_id"]
        if(alert_id_op != nil){
            alert_id_str = alert_id_op as! String;
        }

        self.alert_id = alert_id_str
        debugPrint("alert_id : \(alert_id_str)")
        
        getMessageFromServer(alert_id: alert_id_str)
    }

    //
    //  フォアグラウンド通知のためのメソッド
    //
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("willPresent")
        if notification.request.trigger is UNPushNotificationTrigger {
            debugPrint("プッシュ通知受信")
            //getAlertMessage(userinfo: notification.request.content.userInfo)
        }
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        debugPrint("didReceive")
        getAlertMessage(userinfo: response.notification.request.content.userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        debugPrint("didReceiveRemoteNotification")
        completionHandler(.newData)
        
    }

}

