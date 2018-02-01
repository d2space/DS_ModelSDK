//
//  DS_Model.swift
//  DS_ReflectDemo
//
//  Created by d2space on 2018/1/24.
//  Copyright © 2018年 D2space. All rights reserved.
//


/**
 * 一、Json to model: NSObject  已实现：
 * 1、DS_Model的这2个方法可用，但显low
 * 2、NSObject的2个扩展方法也用
 *
 * 二、Notice: 需要完善的
 * 1、若需要补充replace字段，可以通过protocol去实现，具体可以参考TTReflect
 * 2、Json to model(class)
 * 3、Json to model(struct)
 */

import Foundation
//MARK: 这块思路参考的是MJExtension
extension NSObject{
    //字典转模型
    public class func ds_mapObj(_ json: Any?) -> Self{
        let a = self.init()
        a.ds_property(json as Any)
        return a
    }
    
    //字典转模型数组
    public class func ds_mapObjs( _ json: Any?) -> NSMutableArray{
        guard let json = json else {return [self.init()]}
        guard json is Array<Any> || json is [Any] else {return [self.init()]}
        guard let arr = json as? [Any] else{return [self.init()]}
        let models = NSMutableArray()
        if arr.count > 0{
            for item in arr{
                models.add(ds_mapObj(item))
            }
        }
        return models
    }
    
    fileprivate func ds_property(_ json: Any){
        let keys = ds_propertyKeys()
        if let dic = json as? Dictionary<String, Any>{
            for property_Key in keys{
                if let value = dic[property_Key]{
                    if value is Array<Any>{
                        //数组类型转模型数组
                        if let dics = value as? Array<Any>{
                            if dics.count > 0{
                                if let clsName = ds_classNameFromArr(property_Key){
                                    let models = ds_Objs(dics, clsName)
                                    setValue(models, forKey: property_Key)
                                }
                            }
                        }
                    }else if value is Dictionary<String, Any>{
                        //字典类型转模型
                        if let clsName = ds_classNameFromDic(property_Key){
                            if let model = ds_Obj(clsName){
                                model.ds_property(value)
                                setValue(model, forKey: property_Key)
                            }
                        }
                    }else{
                        //基础类型全部转string
                        let valueStr = String(describing: value)
                        self.setValue(valueStr, forKey: property_Key)
                    }
                }
            }
        }
    }
    //获取模型下的所有property_Key
    fileprivate func ds_propertyKeys() -> Array<String>{
        let m_obj = Mirror(reflecting: self)
        return m_obj.children.flatMap {$0.label}
    }
    //从数组中获取类名
    fileprivate func ds_classNameFromArr(_ propertyKey: String) -> String?{
        let m_obj = Mirror(reflecting: self)
        for item in m_obj.children{
            if item.label == propertyKey{
                let m_subObj = Mirror(reflecting: item.value)
                
                var className: String = String(m_subObj.description)
                if className.contains("Mirror for Optional<Array<") == true{
                    className = className.replacingOccurrences(of: "Mirror for Optional<Array<", with: "")
                    if className.contains(">") == true{
                        className = className.replacingOccurrences(of: ">", with: "")
                        return className
                    }
                }
            }
        }
        return nil
    }
    //从字典中获取类名
    fileprivate func ds_classNameFromDic(_ propertyKey: String) -> String?{
        let m_obj = Mirror(reflecting: self)
        for item in m_obj.children{
            if item.label == propertyKey{
                let m_subObj = Mirror(reflecting: item.value)
                var className = String(m_subObj.description)
                if className.contains("Mirror for Optional<") == true{
                    className = className.replacingOccurrences(of: "Mirror for Optional<", with: "")
                    if className.contains(">") == true{
                        className = className.replacingOccurrences(of: ">", with: "")
                        return className
                    }
                }
            }
        }
        return nil
    }
    //string 转 实例对象，对象为nsobject
    fileprivate func ds_Obj(_ className: String) -> NSObject?{
        let path = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let cls = Bundle.main.classNamed(path + "." + className) as? NSObject.Type{
            return cls.init()
        }
        return nil
    }
    
    //获取实例对象数组
    fileprivate func ds_Objs(_ dics:  Array<Any>,_ clsName: String) -> NSMutableArray{
        let models = NSMutableArray()
        for dic in dics{
            if let model = ds_Obj(clsName){
                model.ds_property(dic)
                models.add(model)
            }
        }
        return models
    }
}
