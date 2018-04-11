//
//  ChannelTableView.swift
//  SlackClient
//
//  Created by Azuma on 2017/09/08.
//  Copyright © 2017年 Azuma. All rights reserved.
//

import UIKit
import SwiftyJSON

let channel_names = ["general", "random"]
class ChannelTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

struct Channel {
    let name: String
    let id: String
    
    init(json: JSON) {
        name = json["name"].stringValue
        id = json["id"].stringValue
    }
}

class View: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var didSelect: (String, String) -> () = { _,_ in }
    var num: Int = 0
    
    var channels: [Channel] = []
    @IBOutlet weak var tableView: ChannelTableView!
    var flag = 0
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "channels"
    }
    
    // cellの高さ
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    
    //cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        tableView.alpha = 0
        num = channel_count()
        return channel_names.count
    }
    
    //cell情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") as! ChannelViewCell
        
//        print("channel_name \(channels[indexPath.item].name)")
        
        cell.channel_name.text = channel_names[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("didSelectRowAt")
        var url: String = ""
        var name: String = ""
        if indexPath.item == 0{
            url = "https://slack.com/api/channels.history?token=accessToken&channel=channelID&pretty=1"
            name = "general"
        } else if indexPath.item == 1 {
            url = "https://slack.com/api/channels.history?token=accessToken&channel=channnelID&pretty=1"
            name = "random"
        }
        tableView.alpha = 0
        didSelect(url, name)
    }
    
    func channel_count() -> Int{
        let url = "https://slack.com/api/rtm.start"
        let token = "accessToken"
        Request(
            path: url,
            method: .get,
            parameters: [
                "token" : token,
                "pretty" : "1",
                ]
            ).request(
                success: { (data) in
                    let json = JSON(data)
                    
                    if (self.channels.isEmpty) {
                        self.channels = json["channels"]
                            .arrayValue
                            .map(Channel.init(json: ))
                        print("data \(data)")
                        print("json \(json)")
                        print(self.channels)
                    }
                    
                    if self.flag == 0 || self.flag == 1{
                        self.tableView.reloadData()
                        self.flag += 1
                    }
                    
            }) { (e) in
                
        }
        print(channels.count)
        return channels.count
    }
}
