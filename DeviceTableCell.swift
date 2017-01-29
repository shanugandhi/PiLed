//
//  DeviceTableCell.swift
//  PiLed
//
//  Created by Tejaswi Rohit Anupindi on 11/9/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

class DeviceTableCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceIP: UILabel!
    @IBOutlet weak var powerSwitch: UISwitch!
    var deviceMac: String!
    var hostPort: String!
    var hostName: String!
    var socket: WebSocket!
    var service: NetService!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getSwitchState(){
        let server = "ws://\(hostName!):\(hostPort!)"
        socket = WebSocket(url: URL(string: server)!)
        socket.connect()
        socket.onConnect = {
            print("Connected")
            self.socket.write(string: "{\"request\":\"get\",\"type\":\"switch\"}")
        }
        socket.onText = {(text: String) in
            print("recived message", text)
            let json_message = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!) as! [String:Any]
            let value = Int((json_message?["value"] as? String)!) != 0
            self.powerSwitch.isOn = value
        }
    }
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        
        let server = "ws://\(hostName!):\(hostPort!)"
        print(server)
        socket = WebSocket(url: URL(string: server)!)
        socket.connect()
        socket.onConnect = {
            print("\(self.hostName) Connected")
            let value = self.powerSwitch.isOn ? 1 : 0
            let message = "{\"request\":\"set\",\"type\":\"switch\",\"value\":\"\(value)\"}"
            self.socket.write(string: message)
            self.socket.disconnect()
        }
    }
    

    

}
