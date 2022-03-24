//
//  SCSweeperCleaningMapView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

class SCSweeperCleaningMapView: SCBasicView {
    /// 是否在动画中
    var isAnimating: Bool = false
    
    var planType: SCSweeperCleaningPlanType = .auto {
        didSet {
            self.planView.type = self.planType
        }
    }
    
    var customRooms: [SCSweeperCleaningCustomPlanRoomModel] = [] {
        didSet {
            self.planView.customRooms = self.customRooms
        }
    }
    
    private var closeBlock: (() -> Void)?
    
    /// 选择房间block
    private var selectCustomRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    /// 编辑房间block
    private var editCustomRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    
    private var changePlanTypeBlock: ((SCSweeperCleaningPlanType) -> Void)?
    
    private lazy var closeButton: UIButton = UIButton(image: "", target: self, action: #selector(closeButtonAction), imageEdgeInsets: UIEdgeInsets())
    
    private lazy var planView: SCSweeperCleaningPlanView = SCSweeperCleaningPlanView { [weak self] type in
        self?.changePlanTypeBlock?(type)
    } selectCustomRoomHandler: { [weak self] room in
        self?.selectCustomRoomBlock?(room)
    } editCustomRoomHandler: { [weak self] room in
        self?.editCustomRoomBlock?(room)
    }

    
    convenience init(closeHandler: (() -> Void)?, changePlanTypeHandler: ((SCSweeperCleaningPlanType) -> Void)?, selectCustomRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?, editCustomRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?) {
        self.init(frame: .zero)
        self.closeBlock = closeHandler
        self.changePlanTypeBlock = changePlanTypeHandler
        
        self.selectCustomRoomBlock = selectCustomRoomHandler
        self.editCustomRoomBlock = editCustomRoomHandler
    }
    
    func show(offsetY: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.isAnimating = true
            var rect = self.frame
            rect.origin.y = offsetY
            self.frame = rect
        } completion: { [weak self] _ in
            self?.isAnimating = false
        }
    }
    
    func hide(offsetY: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.isAnimating = true
            var rect = self.frame
            rect.origin.y = offsetY
            self.frame = rect
        } completion: { [weak self] _ in
            self?.isAnimating = false
        }
    }
}

extension SCSweeperCleaningMapView {
    override func setupView() {
        self.addSubview(self.closeButton)
        
        self.addSubview(self.planView)
        
        #if DEBUG
        self.closeButton.backgroundColor = .red
        self.backgroundColor = .black
        #endif
    }
    
    override func setupLayout() {
        self.closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
            make.top.equalToSuperview().offset(40)
        }
        self.planView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(40 + 30)
        }
    }
}


extension SCSweeperCleaningMapView {
    @objc private func closeButtonAction() {
        self.closeBlock?()
    }
}
