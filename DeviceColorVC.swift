//
//  DeviceColorVC.swift
//  PiLed
//
//  Created by Shanu Gandhi on 11/16/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

import QuartzCore


class DeviceColorVC: CardViewController, WebSocketDelegate, UITableViewDelegate,ChromaColorPickerDelegate,UITableViewDataSource {
    var colorPicker: ChromaColorPicker!
    var colorPickerInitialized: Bool!
    var socketConnection: WebSocket!
    var responseColor: UIColor!
    var colorArray:[UIColor] = []
    var colorCGArray:[[CGFloat]] = []
    
    
    @IBOutlet var colorView: UIView!
    
  
    @IBOutlet var colorTableView: UITableView!
    
    override func viewDidLoad() {
        let server = "ws://\(self.service.hostName!):\(self.service.port)"
        socketConnection = WebSocket(url: URL(string: server)!)
        socketConnection.delegate = self
        socketConnection.connect()
        colorPickerInitialized = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged), name: Notification.Name("Color Changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name("App Coming Foreground"), object: nil)
        
        
        var pickerOriginDiv:CGFloat!
        let screenHeight = UIScreen.main.bounds.size.height
        if screenHeight == 568 { pickerOriginDiv = 1.6 }
        else if screenHeight == 667 { pickerOriginDiv = 1.5 }
        else if screenHeight == 736 { pickerOriginDiv = 1.4 }
        else { pickerOriginDiv = 2.3 }
        
        let pickerSize = CGSize(width: view.bounds.width*0.85, height: view.bounds.width*0.85)
        let pickerOrigin = CGPoint(x: view.bounds.midX - pickerSize.width/2, y: view.bounds.midY - (pickerSize.height/pickerOriginDiv))
        
        //Create Color Picker
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        colorPicker.delegate = self
        colorPicker.hexLabel.isHidden = true
        colorPicker.layout()
        // rounding corners
        colorView.layer.cornerRadius = 5
        colorView.layer.masksToBounds = true
        
        self.view.addSubview(colorPicker)
        
        colorTableView.delegate = self
        colorTableView.dataSource = self
       
        loadSavedColors()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
            print(color)
            let colorCG = color.cgColor
            self.colorArray.insert(color, at: 0)
            let components = colorCG.components
        
            colorCGArray.insert(components! ,at:0)
        
            UserDefaults.standard.set(self.colorCGArray, forKey: "colorList")
            self.colorTableView.reloadData()
            print("Color add pressed")
    }
    
  
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = colorArray[indexPath.row]
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            colorArray.remove(at: indexPath.row)
            colorCGArray.remove(at: indexPath.row)
            UserDefaults.standard.set(self.colorCGArray, forKey: "colorList")
            colorTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        colorPicker.adjustToColor((tableView.cellForRow(at: indexPath)?.backgroundColor)!)
        NotificationCenter.default.post(name: Notification.Name("Color Changed"), object: nil, userInfo: ["color":tableView.cellForRow(at: indexPath)!.backgroundColor!])
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func tableViewClearSelection(){
        for index in 0..<colorArray.count{
            self.colorTableView.cellForRow(at: IndexPath.init(row: index, section: 0))?.accessoryType = UITableViewCellAccessoryType.none
        }
    }

    func colorChanged(notification: Notification){
        let userInfo = notification.userInfo as! [String:Any]
        let color = userInfo["color"] as! UIColor
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red*255>0 ? (red*255) : 0
        green = green*255>0 ? (green*255) : 0
        blue = blue*255>0 ? (blue*255) : 0
        let rgbArray = [Int(red),Int(green),Int(blue)]
        var hue = CGFloat(0), sat = CGFloat(0), bri = CGFloat(0)
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)

        color.getHue(&red, saturation: &green, brightness: &blue, alpha: &alpha)
        color.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: CGColorRenderingIntent.defaultIntent, options: nil)

        var requestDictionary = [String:Any]()
        requestDictionary["request"] = "set"
        requestDictionary["type"] = "color"
        requestDictionary["value"] = rgbArray
        let jsonData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        if socketConnection.isConnected{
            socketConnection.write(string: jsonString!)
        }
        tableViewClearSelection()
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
        let responseDictionary = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!) as! [String:Any]
        if responseDictionary!["type"] as! String == "color"{
            let rgbValues = responseDictionary!["value"] as! [Float]
            responseColor = UIColor(colorLiteralRed: rgbValues[0]/255.0, green: rgbValues[1]/255.0, blue: rgbValues[2]/255.0, alpha: 1.0)
            colorPicker.adjustToColor(responseColor)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    func loadSavedColors()
    {
        let defaults = UserDefaults.standard
        if(defaults.value(forKey: "colorList") != nil)
        {
            colorCGArray = defaults.value(forKey: "colorList") as! [[CGFloat]]
            
            for color in colorCGArray{
                let getColor = UIColor(red: color[0], green: color[1], blue: color[2], alpha: color[3])
                colorArray.append(getColor)
            }
        }
    }
    
    deinit {
        if socketConnection != nil{
            socketConnection.disconnect()
        }

        NotificationCenter.default.removeObserver(self, name: Notification.Name("Color Changed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Coming Foreground"), object: nil)
    }
    
    func applicationDidEnterBackground(){
        socketConnection.disconnect()
    }
    
    func applicationWillEnterForeground(){
        socketConnection.connect()
    }
}
