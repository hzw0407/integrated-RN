//
//  SCAddFamilyModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

enum SCAddFamilyItemType: Int {
    case name
    case location
    case device
    case room
    case member
}


class SCAddFamilyItemModel {
    var type: SCAddFamilyItemType = .name
    var image: ThemeImagePicker?
    var name: String = ""
    var placeholder: String = ""
    var content: String = ""
    
    var hasNext: Bool = false
}
