//
//  ViewController.swift
//  TrainDemo
//
//  Created by 吴海恒 on 2023/1/30.
//

import UIKit
import Contacts

class Contacter:NSObject {
    @objc var name = ""
    @objc var phone = ""
    
    @objc func getName() -> String {
        return self.name
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let identifier = "Cell"
    // 通讯录数据
    var contactesArray:[Contacter] = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    func initUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
        
    }
    
    

    @IBAction func getContacts(_ sender: Any) {
        print("获取联系人")
        self.requestContactPermission()
    }
    
    //查看通讯录权限
    func requestContactPermission() {
        
        let status = CNContactStore .authorizationStatus(for: .contacts)
        if status == .notDetermined {
            //用户还没有就应用程序是否可以访问联系人数据做出选择。
            //请求弹窗选择
            let store = CNContactStore.init()
            store.requestAccess(for: .contacts) { (granted, error) in
                if (error != nil) {
                   print("授权失败")
                }else {
                    //授权成功，访问数据
                    DispatchQueue.main.async {
                        self .loadData()
                    }
                }
            }
        }else if status == .restricted {
            //用户没有权限，家长控制这些导致用户没有访问权限
        }else if status == .denied {
            //用户拒绝访问，引导用户打开通讯录权限
        }else if status == .authorized {
            //用户已同意访问，访问数据
            self.loadData()
        }
    }
    
    //读取通讯录数据
    func loadData() {
        self.contactesArray.removeAll()
        
        /*
         CNContactGivenNameKey联系人的名字
         CNContactFamilyNameKey联系人的姓氏
         CNContactPhoneNumbersKey电话号码
         */
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,CNContactFamilyNameKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        let contactStore = CNContactStore.init()
        
        try?contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) in
            
            //姓名
            let name = contact.familyName + contact.givenName
            //电话
            let phoneNumbers = contact.phoneNumbers
            for labelValue in phoneNumbers {
                
                let contacter = Contacter.init()
                var phoneNumber = labelValue.value.stringValue
                //对电话号码的数据进行整理
                phoneNumber = phoneNumber.replacingOccurrences(of: "+86", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
                phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
                print("姓名=\(name), 电话号码是=\(phoneNumber)")
                contacter.name = name
                contacter.phone = phoneNumber
                self.contactesArray.append(contacter)
                
            }
        })

        self.tableView.reloadData()
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = self.contactesArray[indexPath.row].name + "    " + self.contactesArray[indexPath.row].phone
        return cell
    }
    
}

