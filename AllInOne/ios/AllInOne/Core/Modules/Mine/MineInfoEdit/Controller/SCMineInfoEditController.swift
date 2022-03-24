//
//  SCMineInfoEditController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

class SCMineInfoEditController: SCBasicViewController {
    
    private let viewModel = SCMineViewModel()
    
    var dataModel: SCNetResponseUserProfileModel?
    /// 头像
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFill, cornerRadius: 40)
    /// 编辑按钮
    private lazy var photoButton: UIButton = {
        let btn = UIButton(image: "Mine.SCMineInfoEditController.photoButton.image", target: self, action: #selector(photoButtonAction))
        return btn
    }()
    /// 用户名
    private lazy var accountLabel: UILabel = UILabel(textColor: "Mine.MineController.SCMinePersonInfoHeaderView.accountLabel.textColor", font: "Mine.MineController.SCMinePersonInfoHeaderView.accountLabel.font", alignment: .right)
    /// 编辑按钮
    private lazy var editButton: UIButton = {
        let btn = UIButton(image: "Mine.SCMineInfoEditController.editButton.image", target: self, action: #selector(editButtonAction))
        return btn
    }()
    /// 头
    private lazy var headerView: UIView = {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 159))
        return headerView
    }()
    
    /// 头像编辑
    private lazy var photoSelectAlert: SCMinePhotoSelectAlert = {
        let photoSelectAlert = SCMinePhotoSelectAlert.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: self.view.bounds.size.width, height: 254 - 36 + 34))
        photoSelectAlert.actionBlock = { [unowned self] (type) in
            if type == .camera {
                // 照相
                print("照相")
            } else {
                // 相册
                SCPhotoBrowser.pushPhotoLibrary(maxSelectCount: 1) { image in
                    
                    self.avatarImageView.image = image?.first
                    self.uploadButtonAction()
                    
                }
                print("相册")
            }
        }
        return photoSelectAlert
    }()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineInfoEditTextCell.self, cellIdendify: SCMineIconAndArrowCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped) { [unowned self] (indexPath) in
            self.pushVC(indexPath: indexPath)
        }
        tableView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = self.headerView
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        return tableView
    }()
    /// 数据
    var dataArray: NSArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func pushVC(indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                print("0")
            case 1:
                /// 修改密码
                self.navigationController?.pushViewController(SCMineChangePasswordController(), animated: true)
            case 2:
                /// 绑定手机
                let vc = SCMineBindController()
                vc.type = SCMineBindType.phoneBinding
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                /// 绑定邮箱
                let vc = SCMineBindController()
                vc.type = SCMineBindType.emailBinding
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        } else if indexPath.section == 1 {
            /// 注销
          self.navigationController?.pushViewController(SCMineAccountCancellationVC(), animated: true)
            
        }
    }

}

extension SCMineInfoEditController {    
    override func setupView() {
        self.view.addSubview(self.tableView)
        self.headerView.addSubview(self.avatarImageView)
        self.headerView.addSubview(self.photoButton)
        self.headerView.addSubview(self.accountLabel)
        self.headerView.addSubview(self.editButton)
        
        /// 这里需要自己替换图片
        self.avatarImageView.image = UIImage.init(named: "img_head_h72")
        self.photoButton.setImage(UIImage.init(named: "mine_potho_btn"), for: .normal)
        self.accountLabel.text = "杉川"
    }
    
    override func setupLayout() {
        let rectStatus = UIApplication.shared.statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame;
        let top = ((rectNav?.size.height ?? 0.0) + rectStatus.size.height)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.left.right.bottom.equalTo(0)
        }
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.height.width.equalTo(80)
            make.centerX.equalToSuperview()
        }
        self.photoButton.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.bottom.right.equalTo(self.avatarImageView)
        }
        self.accountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
           // make.right.equalTo(self.headerView.snp.centerX).offset(0)
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(17)
          //  make.left.equalTo(0)
            make.height.equalTo(25)
        }
        self.editButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 20, height: 20))
            make.left.equalTo(self.accountLabel.snp.right).offset(3)
            make.centerY.equalTo(self.accountLabel)
        }
    }

    override func setupData() {
        if dataModel?.phone == "" {
            dataModel?.phone = "未绑定"
        }
        
        if dataModel?.email == "" {
            dataModel?.email = "未绑定"
        }
        
        let avatarPath = SCSmartNetworking.sharedInstance.getHttpPath(forPath: dataModel?.avatarUrl ?? "")
        if let url = URL(string: avatarPath) {
            self.avatarImageView.sd_setImage(with: url, placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
        
        accountLabel.text = dataModel?.nickname
        
        let arrOne = NSMutableArray()
        arrOne.add("1122")
        arrOne.add("")
        arrOne.add(dataModel?.phone ?? "未绑定")
        arrOne.add(dataModel?.email ?? "未绑定")
        
        let arrTwo = NSMutableArray()
        arrTwo.add("")
        
        let allaRR = NSMutableArray()
        allaRR.add(arrOne)
        allaRR.add(arrTwo)
        
        self.viewModel.subTitlts = allaRR as! [[String]]
        self.dataArray = self.viewModel.initEidtData()
        self.tableView.set(list: self.dataArray as! [[Any]])
    }
}

extension SCMineInfoEditController {
    @objc private func photoButtonAction() {
        self.photoSelectAlert.showIn(superView: self.view)

    }
    @objc private func editButtonAction() {
        SCAlertView.alertText(title: "修改昵称", range: NSRange(location: 0, length: 12), placeholder: "请输入昵称", supplement: "确定", cancelCallback: {
            
        }, confirmCallback: { text in
            self.viewModel.modifyUserNicknameRequest(nickname: text) { err in
                if err == nil {
                    self.accountLabel.text = text
                    SCAlertView.hide()
                    
                }
            }
            
        }, isNeedManualHide: true)

    }
    
    @objc private func uploadButtonAction() {
//        #if DEBUG
//        SCSmartNetworking.sharedInstance.modifyUserNicknameRequest(nickname: "先王") {
//
//        } failure: { error in
//
//        }
//
//        SCSmartNetworking.sharedInstance.getUserNicknameRequest { _ in
//
//        } failure: { error in
//
//        }
//        #endif
        
        SCProgressHUD.showWaitHUD()
//        guard let data = self.avatarImageView.image?.jpegData(compressionQuality: 1) else { return }
        guard let data = self.avatarImageView.image?.compressImageQuality(toByte: 256 * 1024) else { return }
        let day = "01-01-2022"
        let timestampString = "0046690461"
        let fileName = timestampString + "_" + (SCUserCenter.sharedInstance.user?.id ?? "") + ".jpg"
        let directory = SCUserCenter.sharedInstance.netConfig.tenantId + "/" + SCUserCenter.sharedInstance.netConfig.projectType + "/" + "avatar" + "/" + day + "/" + fileName
//        let directory = fileName
        SCSmartNetworking.sharedInstance.uploadData(directory: directory, serviceType: .image, data: data) { progress in
            
        } success: { url in
            SCSmartNetworking.sharedInstance.modifyUserAvatarRequest(url: url) { [weak self] in
                SCProgressHUD.hideHUD()
                guard self != nil else { return }
                let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: url)
                SDImageCache.shared.removeImage(forKey: path)
                //self.model?.avatarUrl = path
            } failure: { error in
                SCProgressHUD.showHUD(error.msg)
            }
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("上传失败"))
        }
        
        
//        SCSmartNetworking.sharedInstance.uploadFileRequest(direction: "TEST01/personerPic.jpg", district: SCUserCenter.sharedInstance.country?.ab ?? "CHN", fileName: "personerPic.jpg", data: data) { result in
//            if let url = result {
//                SCSmartNetworking.sharedInstance.modifyUserAvatarRequest(url: url) { [weak self] in
//                    SCProgressHUD.hideHUD()
//                    guard self != nil else { return }
//                    let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: url)
//                    SDImageCache.shared.removeImage(forKey: path)
//                    //self.model?.avatarUrl = path
//                } failure: { error in
//                    SCProgressHUD.showHUD(error.msg)
//                }
//
//            }
//        } failure: { error in
//            SCProgressHUD.hideHUD()
//        }

    }
}
