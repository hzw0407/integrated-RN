//
//  SCMineViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

class SCMineViewModel: SCBasicViewModel {
    typealias RequestBlock = (_ statusCode:String)->Void;
    var model: SCNetResponseUserProfileModel?
    var subTitlts = [
        ["", "", "", tempLocalize("未绑定")],
        [""],
    ]
    
    var isLoadedProfile: Bool = false
    
    func loadData(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getUserProfileRequest(isCache: !isLoadedProfile) { [weak self] responseModel in
            guard let `self` = self else { return }
            self.model = responseModel
            self.isLoadedProfile = true
            success?()
        } failure: { error in
            
        }

    }
    
    func initData() -> NSArray {
        let dataArray = NSMutableArray()
        let imageNames = [
            ["mine_share", "mine_haocai", "mine_home"],
            ["mine_setting", "mine_help", "mine_agreement", "mine_about_us"],
        ]
        let titlts = [
            [tempLocalize("共享"), tempLocalize("设备耗材"), tempLocalize("家庭/房间管理")],
            [tempLocalize("设置"), tempLocalize("帮助与反馈"), tempLocalize("用户协议和隐私政策"), tempLocalize("关于我们")],
        ]
        for section in 0..<imageNames.count {
            let sectionImages = imageNames[section]
            let sectionTitles = titlts[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionImages.count {
                let model = SCMineItemModel.init()
                model.leftIcon = sectionImages[row]
                model.title = sectionTitles[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionImages.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    
    func initEidtData() -> NSArray {
        let dataArray = NSMutableArray()
        let titlts = [
            [tempLocalize("用户ID"), tempLocalize("修改密码"), tempLocalize("绑定手机"), tempLocalize("绑定邮箱")],
            [tempLocalize("注销账号")],
        ]
    
        let cellTypes = [
            [SCMineInfoEditTextCellType.noArrow, SCMineInfoEditTextCellType.textAndArrow, SCMineInfoEditTextCellType.textAndArrow, SCMineInfoEditTextCellType.textAndArrow],
            [SCMineInfoEditTextCellType.textAndArrow],
        ]
        for section in 0..<titlts.count {
            let sectionTitles = titlts[section]
            let sectionSubTitles = subTitlts[section]
            let sectionCellTypes = cellTypes[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionTitles.count {
                let model = SCMineInfoEditModel.init()
                model.title = sectionTitles[row]
                model.subTitle = sectionSubTitles[row]
                model.cellType = sectionCellTypes[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    func initChangePasswordData() -> NSArray {
        let dataArray = NSMutableArray()
        let titlts = [
            [tempLocalize("原密码验证")],
            [tempLocalize("手机号验证")],
            [tempLocalize("邮箱验证")]
        ]
        let cellTypes = [
            [SCMineInfoEditTextCellType.textAndArrow],
            [SCMineInfoEditTextCellType.textAndArrow],
            [SCMineInfoEditTextCellType.textAndArrow]
        ]
        for section in 0..<titlts.count {
            let sectionTitles = titlts[section]
            let sectionCellTypes = cellTypes[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionTitles.count {
                let model = SCMineInfoEditModel.init()
                model.title = sectionTitles[row]
                model.cellType = sectionCellTypes[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    
    func initModifyPasswordData() -> NSArray {
        let dataArray = NSMutableArray()
        let placeTitlts = [
            [tempLocalize("请输入原密码")],
            [tempLocalize("请输入新密码"), tempLocalize("请再次输入新密码")]
        ]
        for section in 0..<placeTitlts.count {
            let sectionTitles = placeTitlts[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionTitles.count {
                let model = SCMineTextFieldModel.init()
                model.placeTitle = sectionTitles[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    func initResetPasswordData() -> NSArray {
        let dataArray = NSMutableArray()
        let placeTitlts = [
            [tempLocalize("请输入新密码"), tempLocalize("请再次输入新密码")]
        ]
        for section in 0..<placeTitlts.count {
            let sectionTitles = placeTitlts[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionTitles.count {
                let model = SCMineTextFieldModel.init()
                model.placeTitle = sectionTitles[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    
    func initSettingData() -> [[SCMineInfoEditModel]] {
        var dataArray = [[SCMineInfoEditModel]]()
        let titlts = [
            [tempLocalize("APP消息推送"), tempLocalize("设备提示音"), tempLocalize("国家/地区"), tempLocalize("时区"), tempLocalize("多语言"), tempLocalize("清理缓存")],
        ]
        let subTitlts = [
            ["", "", tempLocalize("中国大陆"), tempLocalize("GTM +8:00"), tempLocalize("简体中文"), "200M"],
        ]
        let cellTypes = [
            [SCMineInfoEditTextCellType.arrow,
             SCMineInfoEditTextCellType.arrow,
             SCMineInfoEditTextCellType.textAndArrow,
             SCMineInfoEditTextCellType.textAndArrow,
             SCMineInfoEditTextCellType.textAndArrow,
             SCMineInfoEditTextCellType.textAndArrow]
        ]
        for section in 0..<titlts.count {
            let sectionTitles = titlts[section]
            let sectionSubTitles = subTitlts[section]
            let sectionCellTypes = cellTypes[section]
            var sectionArrayM = [SCMineInfoEditModel]()
            for row in 0..<sectionTitles.count {
                let model = SCMineInfoEditModel.init()
                model.title = sectionTitles[row]
                model.subTitle = sectionSubTitles[row]
                model.cellType = sectionCellTypes[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.append(model)
            }
            dataArray.append(sectionArrayM)
        }
        return dataArray
    }
    
    //APP消息推送数据
    typealias SCMineSettingDataModelBlock = (Any?,Any?, Error?) -> Void
    func SCMineSettingDataModelNet(completHandle: SCMineSettingDataModelBlock? = nil){
        SCSmartNetworking.sharedInstance.getRemoteNotificationConfigRequest{ info in
            let dataArray = NSMutableArray()
            let titlts = [
                [tempLocalize("启用APP消息推送")],
            ]
            let subTitlts = [
                [""],
            ]
            let cellTypes = [
                [SCMineInfoEditTextCellType.switchAction]
            ]
            for section in 0..<titlts.count {
                let sectionTitles = titlts[section]
                let sectionSubTitles = subTitlts[section]
                let sectionCellTypes = cellTypes[section]
                let sectionArrayM = NSMutableArray()
                for row in 0..<sectionTitles.count {
                    let model = SCMineInfoEditModel.init()
                    model.title = sectionTitles[row]
                    model.subTitle = sectionSubTitles[row]
                    model.cellType = sectionCellTypes[row]
                    
                    if info?.open == 1 {
                        model.isSwitchOn = false
                    }else{
                        model.isSwitchOn = true
                    }
                    if row == 0, row == sectionTitles.count - 1 {
                        model.cornerRadiusTop = true
                        model.cornerRadiusBottom = true
                    } else if row == 0 {
                        model.cornerRadiusTop = true
                    } else if row == sectionTitles.count - 1 {
                        model.cornerRadiusBottom = true
                    }
                    sectionArrayM.add(model)
                }
                dataArray.add(sectionArrayM)
            }
            
            //initDoNotDisturbData
            
            
            
            let moredataArray = NSMutableArray()
            let moretitlts = [tempLocalize("消息推送免打扰"),
                              tempLocalize("开启时间"),
                              tempLocalize("关闭时间"),
                              tempLocalize("重复")]
            
            var stringRepresentation = ""
            if info != nil && info?.day != "" {
                let newARRd = self.getArrayFromJSONString(jsonString: info?.day ?? "")
                   let newArr = NSMutableArray()
                
                   for index in newARRd {
                       var num = ""
                       if index as! String == "1" {
                           num = tempLocalize("周一")
                       }
                       if index as! String == "2" {
                           num = tempLocalize("周二")
                       }

                       if index as! String == "3" {
                           num = tempLocalize("周三")
                       }

                       if index as! String == "4" {
                           num = tempLocalize("周四")
                       }

                       if index as! String == "5" {
                           num = tempLocalize("周五")
                       }

                       if index as! String == "6" {
                           num = tempLocalize("周六")
                       }

                       if index as! String == "7" {
                           num = tempLocalize("周日")
                       }


                       newArr.add(num)

                   }
                 stringRepresentation = newArr.componentsJoined(by: "，")
            }
     
            
            
            
            let moresubTitlts = ["",
                            info?.beginTime,
                             info?.endTime,
                                 stringRepresentation]
            let morecellTypes = [
                SCMineInfoEditTextCellType.switchAction,
                SCMineInfoEditTextCellType.textAndArrow,
                SCMineInfoEditTextCellType.textAndArrow,
                SCMineInfoEditTextCellType.textAndArrow,
            ]
            for row in 0..<moretitlts.count {
                let model = SCMineInfoEditModel.init()
                model.title = moretitlts[row]
                model.subTitle = moresubTitlts[row] ?? ""
                model.cellType = morecellTypes[row]
                model.beginTime = info?.beginTime ?? ""
                model.day = info?.day ?? ""
                model.endTime = info?.endTime ?? ""
                
                if info?.notNotice == 1 {
                    model.isSwitchOn = false
                }else{
                    model.isSwitchOn = true
                }
              
                if row == 0, row == moretitlts.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == moretitlts.count - 1 {
                    model.cornerRadiusBottom = true
                }
                moredataArray.add(model)
            }
          
         
          
            completHandle?(dataArray,moredataArray,nil)
            
            
            
        } failure: { error in
            
        }
        
    }
    
    
    /** json 字符串数组*/
    func getArrayFromJSONString(jsonString:String) ->NSArray{
     let jsonData:Data = jsonString.data(using: .utf8)!
            let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if array != nil {
                return array as! NSArray
            }
            return array as! NSArray
        }




        

    func initNoticeSettingData() -> NSArray {
        let dataArray = NSMutableArray()
        let titlts = [
            [tempLocalize("启用APP消息推送")],
        ]
        let subTitlts = [
            [""],
        ]
        let cellTypes = [
            [SCMineInfoEditTextCellType.switchAction]
        ]
        for section in 0..<titlts.count {
            let sectionTitles = titlts[section]
            let sectionSubTitles = subTitlts[section]
            let sectionCellTypes = cellTypes[section]
            let sectionArrayM = NSMutableArray()
            for row in 0..<sectionTitles.count {
                let model = SCMineInfoEditModel.init()
                model.title = sectionTitles[row]
                model.subTitle = sectionSubTitles[row]
                model.cellType = sectionCellTypes[row]
                if row == 0, row == sectionTitles.count - 1 {
                    model.cornerRadiusTop = true
                    model.cornerRadiusBottom = true
                } else if row == 0 {
                    model.cornerRadiusTop = true
                } else if row == sectionTitles.count - 1 {
                    model.cornerRadiusBottom = true
                }
                sectionArrayM.add(model)
            }
            dataArray.add(sectionArrayM)
        }
        return dataArray
    }
    /// 免打扰数据
    typealias SCMineViewModelBlock = (Any?, Error?) -> Void
    func initDoNotDisturbData(completHandle: SCMineViewModelBlock? = nil){
        

        SCSmartNetworking.sharedInstance.getRemoteNotificationConfigRequest{ info in
        
        } failure: { error in
            
        }
        
        
        
        
        //网络请求
        
        
        
        
        let dataArray = NSMutableArray()
        let titlts = [tempLocalize("消息推送免打扰"),
                      tempLocalize("开启时间"),
                      tempLocalize("关闭时间"),
                      tempLocalize("重复")]
        let subTitlts = ["",
                         tempLocalize("开启时间"),
                         tempLocalize("关闭时间"),
                         tempLocalize("重复")]
        let cellTypes = [
            SCMineInfoEditTextCellType.switchAction,
            SCMineInfoEditTextCellType.textAndArrow,
            SCMineInfoEditTextCellType.textAndArrow,
            SCMineInfoEditTextCellType.textAndArrow,
        ]
        for row in 0..<titlts.count {
            let model = SCMineInfoEditModel.init()
            model.title = titlts[row]
            model.subTitle = subTitlts[row]
            model.cellType = cellTypes[row]
            if row == 0, row == titlts.count - 1 {
                model.cornerRadiusTop = true
                model.cornerRadiusBottom = true
            } else if row == 0 {
                model.cornerRadiusTop = true
            } else if row == titlts.count - 1 {
                model.cornerRadiusBottom = true
            }
            dataArray.add(model)
        }
       // return dataArray
    }
    
    func initSettingLanguageData() -> NSArray {
        let dataArray = NSMutableArray()
//        let titlts = [
//            ["简体中文", "English"],
//        ]
        let types: [SCLanguageType] = [.Chinese, .English]
        let sectionArrayM = NSMutableArray()
        for i in 0..<types.count {
            let type = types[i]
            let model = SCMineSettingLanguageModel()
            model.title = type.name
            model.type = type
            model.isSelected = type == SCLocalize.appLanguage()
            if i == 0, i == types.count - 1 {
                model.cornerRadiusTop = true
                model.cornerRadiusBottom = true
            } else if i == 0 {
                model.cornerRadiusTop = true
            } else if i == types.count - 1 {
                model.cornerRadiusBottom = true
            }
            sectionArrayM.add(model)
        }
        
        dataArray.add(sectionArrayM)
        
//        for section in 0..<titlts.count {
//            let sectionTitles = titlts[section]
//            let sectionArrayM = NSMutableArray()
//            for row in 0..<sectionTitles.count {
//                let model = SCMineSettingLanguageModel.init()
//                model.title = sectionTitles[row]
//                model.isSelected = row == 0 ? true : false
//                if row == 0, row == sectionTitles.count - 1 {
//                    model.cornerRadiusTop = true
//                    model.cornerRadiusBottom = true
//                } else if row == 0 {
//                    model.cornerRadiusTop = true
//                } else if row == sectionTitles.count - 1 {
//                    model.cornerRadiusBottom = true
//                }
//                sectionArrayM.add(model)
//            }
//            dataArray.add(sectionArrayM)
//        }
        return dataArray
    }
    
    typealias consumableDataBlock = (Any?,Any?, Error?) -> Void
    func initConsumableData(familyId:String,completHandle: consumableDataBlock? = nil) {
        SCSmartNetworking.sharedInstance.getConsumablesInfoByFamilyIdRequest(familyId: familyId, success: {
            response in
            
            let dataArray = NSMutableArray()
            for section in 0..<response.count {
                let modellist = response[section].consumablesList
               // let sectionSubTitles = response[section].consumablesList
                let sectionArrayM = NSMutableArray()
                for row in 0..<modellist.count {
                    let model = SCMineConsumableModel.init()
                    model.title = "\(modellist[row].balance)"
                    model.subTitle = modellist[row].consumablesName
                    model.roomName = "rrr"
                    if row == 0, row == modellist.count - 1 {
                        model.cornerRadiusTop = true
                        model.cornerRadiusBottom = true
                    } else if row == 0 {
                        model.cornerRadiusTop = true
                    } else if row == modellist.count - 1 {
                        model.cornerRadiusBottom = true
                    }
                    sectionArrayM.add(model)
                }
                dataArray.add(sectionArrayM)
            }
            completHandle?(dataArray,response,nil)
        }, failure: { error in
            
        })

        
        
        
        
       
      //  return dataArray
    }
    
    
    //修改用户昵称
    
    typealias modifyUserNicknameBlock = (Error?) -> Void
    func modifyUserNicknameRequest(nickname:String,completHandle: modifyUserNicknameBlock? = nil){
        SCSmartNetworking.sharedInstance.modifyUserNicknameRequest(nickname: nickname) {
            completHandle?(nil)
        } failure: { error in
        
        }

    }
    
    
    
    //获取设备列表
    typealias getDeviceListBlock = (Any?, Error?) -> Void
    func getDeviceListRequest(getDeviceListBlock: getDeviceListBlock? = nil){
        SCSmartNetworking.sharedInstance.getDeviceListRequest { request in
            
            let listModel = NSMutableArray()
            for model in request {
                listModel.add(model.nickname)
            }

            let dataArray = NSMutableArray()
            let titlts = [
                [tempLocalize("开启全部")],
                listModel,
            ]
            let cellTypes = [
                [SCMineInfoEditTextCellType.switchAction],
                [SCMineInfoEditTextCellType.switchAction,
                 SCMineInfoEditTextCellType.switchAction,
                 SCMineInfoEditTextCellType.switchAction]
            ]
            for section in 0..<titlts.count {
                let sectionTitles = titlts[section]
                let sectionCellTypes = cellTypes[section]
                let sectionArrayM = NSMutableArray()
                for row in 0..<sectionTitles.count {
                    let model = SCMineInfoEditModel.init()
                    model.title = sectionTitles[row] as! String
                    model.subTitle = ""
                    model.cellType = sectionCellTypes[row]
                    if row == 0, row == sectionTitles.count - 1 {
                        model.cornerRadiusTop = true
                        model.cornerRadiusBottom = true
                    } else if row == 0 {
                        model.cornerRadiusTop = true
                    } else if row == sectionTitles.count - 1 {
                        model.cornerRadiusBottom = true
                    }
                    sectionArrayM.add(model)
                }
                dataArray.add(sectionArrayM)
            }
            
            
            getDeviceListBlock?(dataArray,nil)
        } failure: { error in
            
        }

    }
  
}
