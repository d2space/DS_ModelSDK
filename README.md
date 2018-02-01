# DS_ModelSDK
JsonString To ObjcModel


import UIKit
import DS_ModelSDK

@objcMembers
class Bank: NSObject{
    var id: String?
    var name: String?
}

@objcMembers
class Card: NSObject{
    var id: String?
    var name: String?
    var bank: Bank?
}
@objcMembers
class User: NSObject{
    var name: String?
    var age: Int = 0
    var cards:[Card]?
    var card: Card?
}

struct House{
    var address: String?
    init(){}
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //测试调用方法,多层字典数组转模型
        let dic = ["name": "d2space",
                   "age": "25",
                   "cards":[["name":"金融","id":"1"],["name":"乐购","id": "2"]],
                   "card":["name": "家乐福", "id": "1005","bank":["id": "005","name": "招商银行"]]] as [String : Any]
        let u = User.ds_mapObj(dic)
        print(u.card?.bank?.name ?? "")
        print(u.cards?.last?.name ?? "")
        
        //测试调用方法，字典转模型数组
        let arr = [["name": "光大银行", "id": "007"],["name": "工商银行", "id": "008"],["name": "中国银行", "id": "009"]]
        let banks = Bank.ds_mapObjs(arr) as? [Bank]
        print((banks?.last?.name)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
        
