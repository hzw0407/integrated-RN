//
//  SCPerformanceTool.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/4.
//

import UIKit

class SCPerformanceTool {
    class func startListening() {
        SCPerformanceFPSTool.shared.startListening()
    }
}

fileprivate class SCPerformanceFPSTool {
    fileprivate static let shared = SCPerformanceFPSTool()
    
    private var link: CADisplayLink?
    private var fps: Double = 0
    /// 帧率计算开始时间
    private var beginTimestamp: TimeInterval = 0
    /// 刷新次数
    private var count: Int = 0
    
    func startListening() {
        if self.link == nil {
            self.link = CADisplayLink(target: self, selector: #selector(tick(_:)))
            self.link?.add(to: RunLoop.current, forMode: .common)
        }
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        // 初始化屏幕渲染时间
        if (self.beginTimestamp <= 0) {
            self.beginTimestamp = link.timestamp
            return;
        }
        
        //刷新次数累加
        self.count += 1
        
        //刚刚屏幕渲染的时间与最开始幕渲染的时间差
        let interval: TimeInterval = link.timestamp - self.beginTimestamp
        if (interval < 1) {
            // 不足1秒，继续统计刷新次数
            return
        }
        
        self.fps = CGFloat(self.count) / CGFloat(link.timestamp - self.beginTimestamp)
        
        #if DEBUG
//        print("fps: \(self.fps)")
        #endif
        // 1秒之后，初始化时间和次数，重新开始监测
        self.beginTimestamp = link.timestamp
        self.count = 0
    }
}
