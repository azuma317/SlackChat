//
//  ViewController.swift
//  SlackClient
//
//  Created by Azuma on 2017/09/07.
//  Copyright © 2017年 Azuma. All rights reserved.
//

import UIKit
import SlackKit
import Alamofire
import SwiftyJSON
import AlamofireImage

// channelの構造体
struct User{
    let account_name: String
    let user_id: String
    let message: String
    
    init(json: JSON) {
        account_name = json["username"].stringValue
        user_id = json["user"].stringValue
        message = json["text"].stringValue
    }
}

// member情報の構造体
struct Member{
    let user_name: String
    let id: String
    let image: String
    
    init(json: JSON){
        user_name = json["real_name"].stringValue
        id = json["id"].stringValue
        image = json["profile"]["image_72"].stringValue
    }
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    let accessToken = "accesstoken"
    @IBOutlet weak var send_message: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    var members: [Member] = []
    var tag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.view as! View).didSelect = { [unowned self] url, name in
            
            self.reloadTabelView(url: url)
            self.channel_name.title = name
            if name == "general"{
                self.tag = 0
            } else {
                self.tag = 1
            }
        }
        
        send_message.delegate = self
        send_message.layer.cornerRadius = 5.0
        tableView.delegate = self
        tableView.dataSource = self
        
        var url = "https://slack.com/api/channels.history?token=\(accessToken)&channel=channelID&pretty=1"
        var api = Request(path: url)
        api.request(success:{ (data: Dictionary) in
            
            let json = JSON(data)
            
//            self.strings = json["messages"].arrayValue.map{ $0["text"].stringValue}
            
            self.users = json["messages"]
                .arrayValue
                .map(User.init(json: ))
            
            self.tableView.reloadData()
            
        },fail:{ (error: Error?) in
                print(error ?? 0)
        })
        
        url = "https://slack.com/api/users.list?token=\(accessToken)&pretty=1"
        api = Request(path: url)
        api.request(success:{ (data: Dictionary) in
            
            let json = JSON(data)
            
            self.members = json["members"]
                .arrayValue
                .map(Member.init(json: ))
            
            self.tableView.reloadData()
            
        },fail:{ (error: Error?) in
            print(error ?? 0)
        })
    }
    
    // messageを送信
    @IBAction func send(_ sender: Any) {
        let message = send_message.text ?? ""
        var channel = "channelID"
        if tag == 1{
            channel = "channelID"
        }
        
        Request(
            path: "https://slack.com/api/chat.postMessage",
            method: .post,
            parameters: [
                "token" : accessToken,
                "channel" : channel,
                "text" : message,
                "as_user" : "azuma",
                "pretty" : "1",
            ]
            )
            .request(success: { (r) in
                var url: String = ""
                if self.tag == 0{
                    url = "https://slack.com/api/channels.history?token=\(self.accessToken)&channel=channelID&pretty=1"
                } else {
                    url = "https://slack.com/api/channels.history?token=\(self.accessToken)&channel=channelID&pretty=1"
                }
                self.reloadTabelView(url: url)
            }) { (e) in
                
        }
        
        inputView_bottom.constant = 0
        send_message.resignFirstResponder()
        send_message.text = ""
    }
    
    @IBOutlet weak var channel_name: UINavigationItem!
    
    //tableViewのreloadを行う
    func reloadTabelView(url: String) -> Void{
        tableView.alpha = 0.5
        tableView.isScrollEnabled = false
        let member_url = "https://slack.com/api/users.list?token=\(accessToken)&pretty=1"
        var api = Request(path: member_url)
        api.request(success:{ (data: Dictionary) in
            
            let json = JSON(data)
            
            self.members = json["members"]
                .arrayValue
                .map(Member.init(json: ))
            
            self.tableView.reloadData()
            
        },fail:{ (error: Error?) in
            print(error ?? 0)
        })
        
        tableView_left.constant = 0
        channel_name.title = ""
        
        api = Request(path: url)
        api.request(success:{ (data: Dictionary) in
            
            let json = JSON(data)
            print(self.users.count)
            self.users = []
            
            self.users = json["messages"]
                .arrayValue
                .map(User.init(json: ))
            
            self.tableView.reloadData()
            self.tableView.alpha = 1
            self.tableView.isScrollEnabled = true
            
        },fail:{ (error: Error?) in
            print(error ?? 0)
        })
    }
    
    // cellの高さ
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    
    //cellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    //cell情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        
        let user = users[users.count-indexPath.item-1]
        let num = getUserNum(id: user.user_id)
        
        cell.photo.af_setImage(withURL: URL(string: members[num].image)!)
        
        cell.message.text = user.message
        
        if getUser(id: user.user_id) != ""{
            cell.user_name.text = getUser(id: user.user_id)
        }else{
            cell.user_name.text = user.account_name
        }
        
        cell.message.sizeToFit()
        
        return cell
    }
    
    //アカウントの写真取得
    func getUserNum(id: String) -> Int{
        
        var num = 0
        for member in members{
            if id == member.id{
                return num
            }
            num += 1
        }
        
        return 0
    }
    
    //アカウントのリアルネーム取得
    func getUser(id: String) -> String{
        
        for member in members{
            if id == member.id{
                return member.user_name
            }
        }
        return ""
        
    }
    
    
    @IBOutlet weak var channelView: ChannelTableView!
    @IBOutlet weak var tableView_left: NSLayoutConstraint!
    @IBAction func channel_change(_ sender: Any) {
        if tableView_left.constant == 0{
            tableView_left.constant = 180
            channelView.alpha = 1
        } else {
            tableView_left.constant = 0
            channelView.alpha = 0
        }
    }
    
    // キーボードのアクション設定
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardDidShowNotification(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    //returnキーをおした時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        inputView_bottom.constant = 0
        
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBOutlet weak var inputView_bottom: NSLayoutConstraint!
    
    // キーボードを表示する直前の処理
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        
        // キーボードの高さを取得し、テキストフィールドをキーボードの高さ分上に移動する
        let userInfo = (notification as NSNotification).userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.inputView_bottom.constant = keyboardScreenEndFrame.size.height
    }
    
    // キーボードを非表示する直前の処理
    func handleKeyboardWillHideNotification(_ notification: Notification) {
    }
    
    // キーボードを表示した直後の処理
    func handleKeyboardDidShowNotification(_ notification: Notification) {
    }
    
    @IBAction func imageSelect(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 選択した写真を取得する
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let image_path = info[UIImagePickerControllerReferenceURL] as! URL
        
        let image_data = UIImageJPEGRepresentation(#imageLiteral(resourceName: "cat"), 0.9)!
        print(image_data)
        print(image_path)
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        //        })
        
        var channel = ""
        
        if tag == 0{
            channel = "C6Y0L4SRH"
        } else if tag == 1{
            channel = "C6Y4J3QGL"
        }
        
//        Alamofire.upload(image_data, to: "https://slack.com/api/files.upload?token=\(accessToken)&channels=C6Y0L4SRH&file_name=test&pretty=1", method: .post, headers: nil).request
        
        Request(
            path: "https://slack.com/api/files.upload",
            method: .post,
            parameters: [
                "token" : accessToken,
                "channels" : channel,
                "content" : image_data,
                "filename" : "image.png",
//                "filetype" : "png",
                "pretty" : "1",
                ]
            )
            .request(success: { (r) in
                print(r)
                var url: String = ""
                if self.tag == 0{
                    url = "https://slack.com/api/channels.history?token=\(self.accessToken)&channel=channnelID&pretty=1"
                } else {
                    url = "https://slack.com/api/channels.history?token=\(self.accessToken)&channel=channelID&pretty=1"
                }
                self.reloadTabelView(url: url)
            }) { (e) in
                
        }
    }

    
}

// post,get
struct Request {
    let url: String
    let method: HTTPMethod
    let parameters: Parameters
    
    init(path: String, method: HTTPMethod = .get, parameters: Parameters = [:]) {
        url = path
        self.method = method
        self.parameters = parameters
    }
    
    func request(success: @escaping (_ data: Dictionary<String, Any>)-> Void, fail: @escaping (_ error: Error?)-> Void) {
        Alamofire.request(url, method: method, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                success(response.result.value as! Dictionary)
            }else{
                fail(response.result.error)
            }
        }
    }
}

//使おうと思ってたけど使わなかったやつ
class SlackImageView: UIImageView{
    
    func loadImage(url: String){
        
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: request, completionHandler:
            { data,response,error in
                
                if error != nil{
                    
                    let image = UIImage(data: data!)
                    
                    self.image = image
                    
                }else{
                    print(error!)
                }
        })
        
    }
}
