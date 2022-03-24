//
//  SCPersonInformationViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

class SCPersonInformationViewController: SCBasicViewController {

    var model: SCNetResponseUserProfileModel?
    
    private var items: [[SCBasicNormalContentModel]] = []
    
    private let viewModel: SCPersonInformationViewModel = SCPersonInformationViewModel()
    
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFill, cornerRadius: 25)
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCBasicNormalContentTableViewCell.self, cellIdendify: SCBasicNormalContentTableViewCell.identify, rowHeight: 50, cellDelegate: self) { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = self.items[indexPath.section][indexPath.row]
            let type = SCPersonInformationType(rawValue: item.id) ?? .uid
            switch type {
            case .changePassword:
                let vc = SCChangePasswordViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .deleteAccount:
                self.viewModel.deleteAccount {
                    
                }
                break
            case .bindEmail:
                #if DEBUG
                let email = "598026478@qq.com"
//                SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: email, type: .modifyEmail) {
//
//                } failure: { error in
//
//                }
                
                SCSmartNetworking.sharedInstance.modifyEmailRequest(email: email, authCode: "376285") {

                } failure: { error in

                }


                #endif
                break
            case .bindPhone:
                #if DEBUG
//                SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: "86-13640950358", type: .modifyPhone) {
//
//                } failure: { error in
//
//                }
                
                SCSmartNetworking.sharedInstance.modifyPhoneRequest(phone: "86-13640950358", authCode: "107583") {

                } failure: { error in

                }


                #endif
                break
            case .bindEmail:
                
                break
            default:
                break
            }
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if var path = self.model?.avatarUrl {
            path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: path)
            self.avatarImageView.sd_setImage(with: URL(string: path), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
    }
}

extension SCPersonInformationViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("修改资料")
    }
    
    override func setupView() {
        
        self.view.addSubview(self.avatarImageView)
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(self.view.snp.topMargin).offset(40)
            make.centerX.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(120)
            make.bottom.equalToSuperview()
        }
    }
    
    override func setupData() {
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageViewGesture))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarTap)
        
        let types: [[SCPersonInformationType]] = [[.uid, .changePassword, .bindPhone, .bindEmail], [.deleteAccount]]
        var sections: [[SCBasicNormalContentModel]] = []
        for (i, tempArray) in types.enumerated() {
            var temp: [SCBasicNormalContentModel] = []
            for (j, type) in tempArray.enumerated() {
                let model = SCBasicNormalContentModel()
                model.title = type.name
                model.hasArrow = type.hasArrow
                model.hasTopLine = i == 0 && j == 0
                model.hasBottomLine = true
                model.id = type.rawValue
                temp.append(model)
            }
            sections.append(temp)
        }
        self.items = sections
        self.tableView.set(list: sections)
    }
    
    @objc private func didTapAvatarImageViewGesture() {
        let vc = SCUploadAvatarViewController()
        vc.model = self.model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
