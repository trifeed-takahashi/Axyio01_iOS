//
//  ViewController.swift
//  Axyio01
//
//  Created by 高橋聖二 on 2017/11/13.
//  Copyright © 2017年 trifeed inc. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var msgText: UITextView!
    @IBOutlet weak var btnConfirm: UIButton!
    
    let push_host : String = NSLocalizedString("push_host", comment: "")
    var myDeviceToken: String = ""
    var alert_id : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
        btnConfirm.setTitleColor(UIColor.white, for: .normal)
        btnConfirm.backgroundColor = UIColor(red:128/255,green:128/255,blue:128/255,alpha:1)
        btnConfirm.layer.borderWidth = 1.0
        btnConfirm.layer.cornerRadius = 10.0 //丸みを数値で変更できます
        btnConfirm.isEnabled = false
        
        msgText.text = "故障は報告されていません"
        //msgText.borderStyle = .none
        msgText.layer.cornerRadius = 5
        msgText.layer.borderColor = UIColor.lightGray.cgColor
        msgText.layer.borderWidth  = 1
        msgText.layer.masksToBounds = true
        
        #if DEBUG
            NSLog("viewDidLoad")
        #endif
    }

    func reloadView(msg : String, mytoken token : String, alert_id id : String){
        self.myDeviceToken = token
        self.alert_id = id
        msgText.text = msg
        btnConfirm.backgroundColor = UIColor(red:255/255,green:0/255,blue:0/255,alpha:1)
        btnConfirm.isEnabled = true
    }

    @IBAction func confirm(_ sender: UIButton) {

        btnConfirm.backgroundColor = UIColor(red:128/255,green:128/255,blue:128/255,alpha:1)
        btnConfirm.isEnabled = false

        let push_url : String = NSLocalizedString("push_alert_confirm", comment: "")
        let request_url = "https://\(push_host)\(push_url)"
        //msgText.text = "故障は報告されていません"

        
        print("deviceToken = \(myDeviceToken)")
        print("Push host = \(push_host)")
        print("Push url = \(push_url)")
        print(request_url);
        
        // サーバへリクエストを行う
        let parameters = [
            "project": "axyio01",
            "devicetoken": myDeviceToken,
            "alert_id": alert_id
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        #if DEBUG
            NSLog("viewWillAppear")
        #endif
    }
}

