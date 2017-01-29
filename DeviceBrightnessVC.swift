//
//  DeviceBrightnessVC.swift
//  PiLed
//
//  Created by Shanu Gandhi on 11/16/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

class DeviceBrightnessVC: CardViewController, WebSocketDelegate {
    
    var socketConnection: WebSocket!
    @IBOutlet var brightnessView: UIView!
    
    @IBOutlet var bulbImageView: UIImageView!
    override func viewDidLoad() {
        
        let server = "ws://\(self.service.hostName!):\(self.service.port)"
        socketConnection = WebSocket(url: URL(string: server)!)
        socketConnection.delegate = self
        socketConnection.connect()
        
        // rounding corners
        brightnessView.layer.cornerRadius = 5
        brightnessView.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name("App Coming Foreground"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    @IBOutlet weak var rgbSlider: UISlider!
    @IBOutlet weak var wledSlider: UISlider!

    @IBAction func rgbBrightnessChanged(_ sender: UISlider) {
        var requestDictionary = [String:String]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "rgbbrightness"
        requestDictionary["value"] = String(Int(sender.value))
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketConnection.write(string: jsonString!)
        bulbImageView.alpha = CGFloat(sender.value+15) / CGFloat(255)
        
    }
    @IBAction func wledBrightnessChanged(_ sender: UISlider) {
        var requestDictionary = [String:String]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "wledbrightness"
        requestDictionary["value"] = String(Int(sender.value))
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketConnection.write(string: jsonString!)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        var requestDictionary = [String:String]()
        requestDictionary["request"] = "get"
        requestDictionary["type"] = "rgbbrightness"
        var jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        var jsonString = String(data: jsonData!, encoding: .utf8)
        socketConnection.write(string: jsonString!)
        
        requestDictionary["type"] = "wledbrightness"
        jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        jsonString = String(data: jsonData!, encoding: .utf8)
        socketConnection.write(string: jsonString!)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let responseDictionary = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!) as! [String:String]
        if responseDictionary!["type"] == "rgbbrightness"{
            rgbSlider.value = Float(responseDictionary!["value"]!)!
            bulbImageView.alpha = CGFloat(rgbSlider.value+15) / CGFloat(255)
        }
        else if responseDictionary!["type"] == "wledbrightness"{
            wledSlider.value = Float(responseDictionary!["value"]!)!
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func applicationDidEnterBackground(){
        socketConnection.disconnect()
    }
    
    func applicationWillEnterForeground(){
        socketConnection.connect()
    }

    deinit {
        socketConnection.disconnect()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Coming Foreground"), object: nil)
    }
}
