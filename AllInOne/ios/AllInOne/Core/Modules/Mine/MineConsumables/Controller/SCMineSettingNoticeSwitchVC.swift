//
//  SCMineSettingNoticeSwitchVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/22.
//

import UIKit


class SCMineSettingNoticeSwitchVC: SCBasicViewController {
    var timePicker: SCMineSettingTimePickerView = {
        let timePicker = SCMineSettingTimePickerView.init()
        return timePicker
    }()
    var weekPicker: SCMineSettingWeekPickerView = {
        let weekPicker = SCMineSettingWeekPickerView()
        return weekPicker
    }()
    var dayString:String = ""
    var dayS:String = ""
    var beginTime:String = ""
    var endTime:String = ""
    var isMxiao:Bool = false //是否开启免消息打扰
    var isBeginTime:Bool = false
    private let viewModel = SCMineViewModel()
    private var editModel: SCMineInfoEditModel?
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineInfoEditTextCell.self, cellIdendify: SCMineInfoEditTextCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            if indexPath.section == 1 {
                self.editModel = self.moreData[indexPath.row]
                switch indexPath.row {
                case 1:
                    self.isBeginTime = true
                    showTimePickView()
                case 2:
                    self.isBeginTime = false
                    showTimePickView()
                case 3:
                    showWeekTimePickView()
                default:
                    return
                }
            }
            
        }
        return tableView
    }()
    /// 数据
    var dataArray: [[SCMineInfoEditModel]] = []
    var moreData: [SCMineInfoEditModel] = []
    var timeInfoString:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // 时间选择
        self.timePicker.timeDidSelectRow = { [unowned self] (hour, minu) in
            self.timeInfoString = hour + ":" + minu
        }
        // 星期选择
        self.weekPicker.weekDidSelectRow = { [unowned self] (weekStr) in
            self.timeInfoString = weekStr
        }
    }
    
    //设置按钮
    func setStingConfig(isOn:Bool,isQuietOn:Bool){
           let myarr:NSArray = self.timeInfoString.split(separator: " ") as NSArray
           let newArr = NSMutableArray()
           for index in myarr {
               var num = ""
               if index as! String == tempLocalize("周一") {
                   num = "1"
               }
               if index as! String == tempLocalize("周二") {
                   num = "2"
               }
               
               if index as! String == tempLocalize("周三") {
                   num = "3"
               }
               
               if index as! String == tempLocalize("周四") {
                   num = "4"
               }
               
               if index as! String == tempLocalize("周五") {
                   num = "5"
               }
               
               if index as! String == tempLocalize("周六") {
                   num = "6"
               }
               
               if index as! String == tempLocalize("周日") {
                   num = "7"
               }
               newArr.add(num)
           }
           self.dayString = arrayToJson(newArr)
           SCSmartNetworking.sharedInstance.setRemoteNotificationRequest(isOn: isOn, isQuietOn:
                                                                            isQuietOn, day: self.dayS, beginTime: self.beginTime, endTime: self.endTime){ Modes in
               self.editModel?.subTitle = self.timeInfoString
             
               self.tableView.set(list: self.dataArray)
               SCAlertView.hide()
           }failure: {  error in
           
           }
           
     
    }
    /// 设置是否可编辑
    func setMoreData(isEnable: Bool) {
        self.moreData.forEach { model in
            if model.title != tempLocalize("消息推送免打扰") {
                model.isEnable = isEnable
                
                
            }
        }
    }
    

    /// 显示时间选择
    func showTimePickView() {
        self.timePicker.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 48, height: 44 * 5)
        SCAlertView.alert(title: tempLocalize("开启时间"), customView: self.timePicker, supplement: tempLocalize("确定"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), cancelCallback: {
            
        }, confirmCallback: { [unowned self] in
         
            
//            if self.dayString == "" {
//                self.dayString = "ALL"
//            }
//
            if self.isBeginTime {
                self.beginTime =  self.timeInfoString
            }else{
                self.endTime =  self.timeInfoString
            }
            
            SCSmartNetworking.sharedInstance.setRemoteNotificationRequest(isOn: false, isQuietOn: true, day: self.dayS, beginTime: self.beginTime, endTime: self.endTime){ Modes in
                self.editModel?.subTitle = self.timeInfoString
                self.tableView.set(list: self.dataArray)
                SCAlertView.hide()
            }failure: {  error in
            
            }
         
      
        }, isNeedManualHide: true)
    }
    /// 显示星期
    func showWeekTimePickView() {
        self.weekPicker.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 48, height: 56 * 7)
        SCAlertView.alert(title: tempLocalize("自定义重复"), customView: self.weekPicker, supplement: tempLocalize("确定"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), cancelCallback: {
            
        }, confirmCallback: { [unowned self] in
            
           
            
         
            let myarr:NSArray = self.timeInfoString.split(separator: " ") as NSArray
            
            let newArr = NSMutableArray()
            for index in myarr {
                var num = ""
                if index as! String == tempLocalize("周一") {
                    num = "1"
                }
                if index as! String == tempLocalize("周二") {
                    num = "2"
                }
                
                if index as! String == tempLocalize("周三") {
                    num = "3"
                }
                
                if index as! String == tempLocalize("周四") {
                    num = "4"
                }
                
                if index as! String == tempLocalize("周五") {
                    num = "5"
                }
                
                if index as! String == tempLocalize("周六") {
                    num = "6"
                }
                
                if index as! String == tempLocalize("周日") {
                    num = "7"
                }
                
                
                newArr.add(num)
                
            }
            self.dayString = arrayToJson(newArr)
            self.dayS = arrayToJson(newArr)
            SCSmartNetworking.sharedInstance.setRemoteNotificationRequest(isOn: false, isQuietOn: true, day: self.dayString, beginTime: self.beginTime, endTime: self.endTime){ Modes in
                self.editModel?.subTitle = self.timeInfoString
              
                self.tableView.set(list: self.dataArray)
                SCAlertView.hide()
            }failure: {  error in
            
            }
            
            self.editModel?.subTitle = self.timeInfoString
          
            self.tableView.set(list: self.dataArray)
            SCAlertView.hide()
        }, isNeedManualHide: true)
    }
    
    
    //数组转JSON
    func arrayToJson(_ array:NSArray)->String{
        
        //首先判断能不能转换
        if (!JSONSerialization.isValidJSONObject(array)) {
            //print("is not a valid json object")
            return ""
        }
        
        //利用OC的json库转换成OC的NSData，
        //如果设置options为NSJSONWritingOptions.PrettyPrinted，则打印格式更好阅读
        let data : Data! = try? JSONSerialization.data(withJSONObject: array, options: [])
        //NSData转换成NSString打印输出
        let str = NSString(data:data, encoding: String.Encoding.utf8.rawValue)
        //输出json字符串
        return str! as String
        
    }

}

extension SCMineSettingNoticeSwitchVC {
    override func setupView() {
        self.title = "APP消息推送"
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func setupData() {
        
        self.viewModel.SCMineSettingDataModelNet(completHandle: { dataArray,moredataArray, error in
            self.dataArray = dataArray as! [[SCMineInfoEditModel]]
            self.tableView.set(list: self.dataArray)
            self.moreData = moredataArray as! [SCMineInfoEditModel]
            self.dataArray[0].forEach { model in
                if model.isSwitchOn {
                    self.dataArray.append(self.moreData)
                    self.tableView.set(list: self.dataArray)
                }
            }
            
            self.moreData.forEach { model in
                if model.title == tempLocalize("开启时间") {
                    self.beginTime = model.beginTime
                }
                if model.title == tempLocalize("消息推送免打扰") {
                    self.isMxiao = model.isSwitchOn
                }
                if model.title == tempLocalize("关闭时间") {
                    self.endTime = model.endTime
                }
              
                if model.title == tempLocalize("重复") {
                    self.dayS = model.day
                }
              
                self.setMoreData(isEnable: !model.isSwitchOn)
            }
            
          
         
                
            })
        
    
        
    }
}


extension SCMineSettingNoticeSwitchVC:SCMineInfoEditTextCellDelegate {
    func cell(_ cell: SCMineInfoEditTextCell, didSelected model: SCMineInfoEditModel) {
        
    }
    
    func cell(_ cell: SCMineInfoEditTextCell, didSwicthAction model: SCMineInfoEditModel, isOpen: Bool) {
        switch model.title {
        case tempLocalize("启用APP消息推送"):
          
            self.setStingConfig(isOn: !isOpen, isQuietOn:self.isMxiao)
            if isOpen == true {
                self.dataArray.append(self.moreData)
            } else {
                self.dataArray.removeLast()
            }
            self.tableView.set(list: self.dataArray)
        case tempLocalize("消息推送免打扰"):
           // setTingNet(isOpen: isOpen)
            
            if isOpen {
                if self.beginTime == "" || self.endTime == "" || self.dayS == ""  {
                        model.isSwitchOn = !isOpen
                        self.tableView.set(list: self.dataArray)
                    
                     return
                   }
            }
      
            
            
           
            self.setMoreData(isEnable: !isOpen)
            self.setStingConfig(isOn: false, isQuietOn: !isOpen)
            //self.setMoreDatad(isEnable: !isOpen)
            self.tableView.set(list: self.dataArray)
        default:
            return
        }
    }
}
