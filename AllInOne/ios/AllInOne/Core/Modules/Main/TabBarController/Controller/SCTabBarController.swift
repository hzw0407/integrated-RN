//
//  SCTabBarController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import ESTabBarController_swift

class SCTabBarController: ESTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let icon1 = ThemeImagePicker(keyPath: "").value() as! UIImage

        let v1 = SCHomePageViewController()
        let v2 = SCSmartSceneViewController()
        let v3 = SCMineViewController()
        
        let nav1 = SCNavigationViewController(rootViewController: v1)
        let nav2 = SCNavigationViewController(rootViewController: v2)
        let nav3 = SCNavigationViewController(rootViewController: v3)
        
        let item1 = ESTabBarItem(SCTabBarBouncesContentView(), title: tempLocalize("tab_home_title"), image: nil, selectedImage: nil)
        item1.theme_image = "Global.TabBar.HomePage.normalImage"
        item1.theme_selectedImage = "Global.TabBar.HomePage.selectImage"
        let item2 = ESTabBarItem(SCTabBarBouncesContentView(), title: tempLocalize("tab_scene_title"), image: nil, selectedImage: nil)
        item2.theme_image = "Global.TabBar.SmartScene.normalImage"
        item2.theme_selectedImage = "Global.TabBar.SmartScene.selectImage"
        let item3 = ESTabBarItem(SCTabBarBouncesContentView(), title: tempLocalize("tab_mine_title"), image: nil, selectedImage: nil)
        item3.theme_image = "Global.TabBar.Mine.normalImage"
        item3.theme_selectedImage = "Global.TabBar.Mine.selectImage"
        
        nav1.tabBarItem = item1
        nav2.tabBarItem = item2
        nav3.tabBarItem = item3

        self.viewControllers = [nav1, nav2, nav3]
        self.tabBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            let barAppearance = UITabBarAppearance()
            barAppearance.theme_backgroundColor = "Global.TabBar.barTintColor"
            barAppearance.backgroundEffect = nil
            self.tabBar.standardAppearance = barAppearance
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = barAppearance
            }
        }
        else {
            (self.tabBar as? ESTabBar)?.itemCustomPositioning = .fillIncludeSeparator
        }
    }
    

}
