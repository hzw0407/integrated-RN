//
//  SCMemberDetailViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCMemberDetailViewController: SCBasicViewController {

    var family: SCNetResponseFamilyModel?
    var member: SCNetResponseFamilyMemberModel?
    
    private let viewModel: SCMemberDetailViewModel = SCMemberDetailViewModel()
    
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", cornerRadius: 60)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.MemberDetailController.nameLabel.textColor", font: "HomePage.FamilyListController.MemberDetailController.nameLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCMemberDetailItemCell.self, cellIdendify: SCMemberDetailItemCell.identify, rowHeight: 68)
    
    private lazy var deleteButton: UIButton = UIButton(tempLocalize("撤销共享"), titleColor: "HomePage.FamilyListController.MemberDetailController.deleteButton.textColor", font: "HomePage.FamilyListController.MemberDetailController.deleteButton.font", target: self, action: #selector(deleteButtonAction), backgroundColor: "HomePage.FamilyListController.MemberDetailController.deleteButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCMemberDetailViewController {
    override func setupView() {
        self.title = tempLocalize("成员信息")
        
        self.view.addSubview(self.avatarImageView)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.deleteButton)
    }
    
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalTo(self.view.snp.topMargin).offset(40)
            make.centerX.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.nameLabel.snp.bottom).offset(34)
            make.bottom.equalTo(self.deleteButton.snp.top).offset(-10)
        }
        self.deleteButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
    }
    
    override func setupData() {
        guard let member = self.member else { return }
        self.avatarImageView.sd_setImage(with: URL(string: member.headUrl), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        var name = member.nickname
        if member.userId == SCSmartNetworking.sharedInstance.user?.id {
            name += tempLocalize("(我)")
        }
        self.nameLabel.text = name
        
        let identity = SCMemberIdentityType(rawValue: member.identity) ?? .admin
        let titles = [tempLocalize("用户ID"), tempLocalize("身份")]
        let contents = [member.userId, identity.name]
        
        var items = [SCMemberDetailItemModel]()
        for (i, title) in titles.enumerated() {
            let item = SCMemberDetailItemModel()
            item.title = title
            item.content = contents[i]
            items.append(item)
        }
        self.tableView.set(list: [items])
        
        self.deleteButton.isHidden = true
        if let family = self.family, let member = self.member {
            if family.isOwner && member.userId != SCSmartNetworking.sharedInstance.user?.id {
                self.deleteButton.isHidden = false
            }
        }
    }
}

extension SCMemberDetailViewController {
    @objc private func deleteButtonAction() {
        SCAlertView.alert(message: tempLocalize("确认撤销共享"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确认"), confirmCallback: { [weak self] in
            guard let `self` = self, let member = self.member, let family = self.family else { return }
            
            self.viewModel.deleteMember(familyId: family.id, inviteId: family.creatorId, beInviteId: member.userId) {
                [weak self] in
                    guard let `self` = self else { return }
                    self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
