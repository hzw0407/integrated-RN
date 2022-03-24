//
//  SCSweeperCleaningCustomPlanView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit

class SCSweeperCleaningCustomPlanView: SCBasicView {

    var rooms: [SCSweeperCleaningCustomPlanRoomModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    /// 折叠展开block
    private var foldBlock: (() -> Void)?
    /// 选择房间block
    private var selectRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    /// 编辑房间block
    private var editRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    
    private lazy var titleView: SCSweeperCleaningPlanTitleView = SCSweeperCleaningPlanTitleView(coverImage: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.customPlanImage", title: tempLocalize("自定义")) { [weak self] in
        self?.foldBlock?()
    }
    
    private lazy var contentView: UIView = UIView(backgroundColor: "PluginSweeperTheme.CleaningViewController.MapView.CustomPlanView.backgroundColor", cornerRadius: 18)
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCSweeperCleaningCustomPlanCell.self, cellIdendify: SCSweeperCleaningCustomPlanCell.identify, rowHeight: 50, cellDelegate: self) { [weak self] indexPath in
        guard let `self` = self else { return }
        guard self.rooms.count > indexPath.row else { return }
        let room = self.rooms[indexPath.row]
        self.editRoomBlock?(room)
    }
    
    convenience init(foldHandler: (() -> Void)?, selectRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?, editRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?) {
        self.init(frame: .zero)
        self.foldBlock = foldHandler
        self.selectRoomBlock = selectRoomHandler
        self.editRoomBlock = editRoomHandler
    }

    func fold() {
        self.titleView.fold()
    }
    
    func unfold() {
        self.titleView.unfold()
    }
}

extension SCSweeperCleaningCustomPlanView {
    override func setupView() {
        self.layer.masksToBounds = true
        self.addSubview(self.titleView)
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        self.contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.titleView.snp.bottom)
            make.height.equalTo(50 * 3 + 20 * 2)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(50 * 3.5)
        }
    }
    
    func reloadData() {
        self.tableView.set(list: [self.rooms])
    }
}

extension SCSweeperCleaningCustomPlanView: SCSweeperCleaningCustomPlanCellDelegate {
    func cell(_ cell: SCSweeperCleaningCustomPlanCell, didClickedSelectButtonWithRoom room: SCSweeperCleaningCustomPlanRoomModel) {
        self.selectRoomBlock?(room)
    }
}
