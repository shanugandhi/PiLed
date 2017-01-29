//
//  DeviceModeVC.swift
//  PiLed
//
//  Created by Shanu Gandhi on 11/16/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit
import QuartzCore

class DeviceModeVC: CardViewController, WebSocketDelegate {
    var socketConnection: WebSocket!

    @IBOutlet weak var staticModeSwitch: UISwitch!
    @IBOutlet weak var rainbowWheelModeSwitch: UISwitch!
    
    @IBOutlet var colorFadeModeSwitch: UISwitch!
    
    @IBOutlet var modeView: UIView!
    
    override func viewDidLoad() {
        let server = "ws://\(self.service.hostName!):\(self.service.port)"
        socketConnection = WebSocket(url: URL(string: server)!)
        socketConnection.delegate = self
        socketConnection.connect()
        
        settingMode()
        // rounding corners
        modeView.layer.cornerRadius = 5
        modeView.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name("App Coming Foreground"), object: nil)
    }
    
    @IBAction func staticFlip(_ sender: UISwitch) {
        
       
       
        if rainbowWheelModeSwitch.isOn == true{
            rainbowWheelModeSwitch.setOn(false, animated: true)
        }
        if colorFadeModeSwitch.isOn == true{
            colorFadeModeSwitch.setOn(false, animated: true)
        }
        
        confMode()
        
        var requestDictionary = [String:Any]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "mode"
        requestDictionary["value"] = "static"
        requestDictionary["code"] = ""
        print(requestDictionary["value"]!)
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        if socketConnection.isConnected{
            socketConnection.write(string: jsonString!)
        }
    }
    
    @IBAction func rainbowWheelFlip(_ sender: UISwitch) {
        
        
        if staticModeSwitch.isOn == true{
            staticModeSwitch.setOn(false, animated: true)
        }
        if colorFadeModeSwitch.isOn == true{
            colorFadeModeSwitch.setOn(false, animated: true)
        }
        
        confMode()

        
        var requestDictionary = [String:Any]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "mode"
        requestDictionary["value"] = "rainbow"
        
        let path = Bundle.main.path(forResource: "RainbowWheel", ofType: ".py")
        requestDictionary["code"] = try? String(contentsOfFile: path!)
        print(requestDictionary["value"]!)
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        if socketConnection.isConnected{
            socketConnection.write(string: jsonString!)
        }
    }
    
    @IBAction func rainbowFlip(_ sender: UISwitch) {
       
       
        
        
        if rainbowWheelModeSwitch.isOn == true{
            rainbowWheelModeSwitch.setOn(false, animated: true)
        }
        
        if staticModeSwitch.isOn == true{
            staticModeSwitch.setOn(false, animated: true)
        }
        
         confMode()
        
        var requestDictionary = [String:Any]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "mode"
        requestDictionary["value"] = "rainbow"
        
        let path = Bundle.main.path(forResource: "Rainbow", ofType: ".py")
        requestDictionary["code"] = try? String(contentsOfFile: path!)
        print(requestDictionary["value"]!)
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        if socketConnection.isConnected{
            socketConnection.write(string: jsonString!)
        }
    }

    
    
    func settingMode(){
        staticModeSwitch.setOn(true, animated: true)
        rainbowWheelModeSwitch.setOn(false, animated: true)
        colorFadeModeSwitch.setOn(false, animated: true)

    }
    
    func confMode(){
        
        if (rainbowWheelModeSwitch.isOn == false && colorFadeModeSwitch.isOn == false){
            staticModeSwitch.isOn = true
            }
    
    
    }
    
    func websocketDidConnect(socket: WebSocket) {
        var requestDictionary = [String:String]()
        requestDictionary["request"] = "get"
        requestDictionary["type"] = "color"
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketConnection.write(string: jsonString!)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {

    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    func applicationDidEnterBackground(){
        socketConnection.disconnect()
    }
    
    func applicationWillEnterForeground(){
        socketConnection.connect()
    }
    
    deinit {
        if socketConnection != nil{
            socketConnection.disconnect()
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Coming Foreground"), object: nil)
    }
}
