//
//  SCFamilyLocationModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCFamilyLocationModel {
    var city: String = ""
    var street: String = ""
    var address: String = ""
    var latitude: CGFloat = 0
    var longitude: CGFloat = 0
    
    var searchKey: String = ""
    
    var locationName: String {
        return self.address
//        return self.city + " " + self.street
    }
}
