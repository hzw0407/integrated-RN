//
//  SCSweeperCleaningMapModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

class SCSweeperCleaningMapModel {
    
    var isPanEnabled: Bool = true
    
    private var panChangedBlock: ((CGFloat) -> Void)?
    private var panEndedBlock: ((CGFloat) -> Void)?
    
    private var lastOffsetY: CGFloat = 0
    
    private var touchView: UIView?
    
    private var isStart: Bool = false
 
    convenience init(panChangedHandler: ((CGFloat) -> Void)?, panEndedHandler: ((CGFloat) -> Void)?) {
        self.init()
        self.panChangedBlock = panChangedHandler
        self.panEndedBlock = panEndedHandler
    }

    func addPanGesture(fromView view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(pan)
        self.touchView = view
    }

    @objc private func panGestureAction(_ gesture: UIPanGestureRecognizer) {
        if !self.isPanEnabled {
            return
        }
        switch gesture.state {
        case .began:
            let startPoint = gesture.location(in: self.touchView)
            if startPoint.y < kSCScreenHeight - 200 {
                return
            }
            self.isStart = true
            self.lastOffsetY = 0
            break
        case .changed:
            if !self.isStart {
                return
            }
            let offsetY = gesture.translation(in: self.touchView).y
            let deltaY = offsetY - self.lastOffsetY
            self.lastOffsetY = offsetY
            self.panChangedBlock?(deltaY)
            break
        case .ended:
            if !self.isStart {
                return
            }
            self.isStart = false
            let offsetY = gesture.translation(in: self.touchView).y
            self.panEndedBlock?(offsetY)
            break
        default:
            break
        }
    }
}
