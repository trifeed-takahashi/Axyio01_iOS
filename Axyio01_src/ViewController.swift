//
//  ViewController.swift
//  Axyio01
//
//  Created by 高橋聖二 on 2017/11/13.
//  Copyright © 2017年 trifeed inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var msgText: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnConfirm.setTitleColor(UIColor.white, for: .normal)
        btnConfirm.backgroundColor = UIColor(red:255/255,green:0/255,blue:0/255,alpha:1)
        
        msgText.text = "故障は報告されていません"
        
        #if DEBUG
            NSLog("viewDidLoad")
        #endif
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

