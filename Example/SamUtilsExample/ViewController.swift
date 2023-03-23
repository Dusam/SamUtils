//
//  ViewController.swift
//  SamUtilsExample
//
//  Created by 杜千煜 on 2023/3/10.
//

import UIKit

class ViewController: UIViewController {
    
    private let TAG = "ViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        API.shared.test()
        
        BluetoothManagerSample.shared.startScan { devices in
            print(devices)

//            if let deviceUUID = devices.first?.deviceUUID {
//                BluetoothManagerSample.shared.connectPeripheral(withUUID: deviceUUID)
//                BluetoothManagerSample.shared.connectPeripheral(withUUID: deviceUUID) { isConnected in
//
//                }
//            }

        }
        
    }
}
