//
//  SCSweeperCleaningCustomPlanRoomEditView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/21.
//

import UIKit

class SCSweeperCleaningCustomPlanRoomEditViewController: SCBasicViewController {

    var room: SCSweeperCleaningCustomPlanRoomModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension SCSweeperCleaningCustomPlanRoomEditViewController {
    override func setupNavigationBar() {
        self.title = self.room?.roomName ?? ""
    }
    
    override func setupView() {
        
    }
    
    override func setupLayout() {
        
    }
}
