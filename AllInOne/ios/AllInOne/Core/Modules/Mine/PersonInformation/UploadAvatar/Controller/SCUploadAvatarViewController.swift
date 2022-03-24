//
//  SCUploadAvatarViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit
import ZLPhotoBrowser
import Alamofire

class SCUploadAvatarViewController: SCBasicViewController {
    
    var model: SCNetResponseUserProfileModel?

    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFill, cornerRadius: 25)
    
    private lazy var uploadButton: UIButton = UIButton(tempLocalize("上传"), titleColor: "Login.loginButton.textColor", font: "Login.loginButton.font", target: self, action: #selector(uploadButtonAction), backgroundColor: "Login.loginButton.backgroundColor", cornerRadius: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}

extension SCUploadAvatarViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("头像")
    }
    
    override func setupView() {
        self.view.addSubview(self.avatarImageView)
        self.view.addSubview(self.uploadButton)
        
        self.avatarImageView.backgroundColor = .yellow
    }
    
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(40)
        }
        
        self.uploadButton.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(40)
            make.height.equalTo(40)
            make.left.right.equalToSuperview().inset(40)
        }
    }
    
    override func setupData() {
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageViewGesture))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarTap)
        
        if var path = self.model?.avatarUrl {
            path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: path)
            self.avatarImageView.sd_setImage(with: URL(string: path), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
    }
    
    @objc private func didTapAvatarImageViewGesture() {
        SCPhotoBrowser.pushPhotoLibrary(maxSelectCount: 1) { images in
            self.avatarImageView.image = images?.first
        }
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
        guard let data = self.avatarImageView.image?.pngData() else { return }
        SCSmartNetworking.sharedInstance.uploadFileRequest(direction: "TEST01/avatar02.png", district: "cn-shenzhen", fileName: "avatar02.png", data: data) { result in
            if let url = result {
                SCSmartNetworking.sharedInstance.modifyUserAvatarRequest(url: url) { [weak self] in
                    SCProgressHUD.hideHUD()
                    guard let `self` = self else { return }
                    let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: url)
                    SDImageCache.shared.removeImage(forKey: path)
                    self.model?.avatarUrl = path
                } failure: { error in
                    SCProgressHUD.showHUD(error.msg)
                }
                
            }
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
}
