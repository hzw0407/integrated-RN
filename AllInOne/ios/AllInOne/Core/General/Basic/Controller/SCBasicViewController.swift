//
//  SCBasicViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/22.
//

import UIKit
import SwiftTheme

class SCBasicViewController: UIViewController {

    private (set) lazy var backBarButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20)
        btn.theme_setImage("Global.NavigationBackItem.image", forState: .normal)
//        btn.theme_setImage("Global.NavigationBackItem.buttonImageHighlighted", forState: .highlighted)
        btn.addTarget(self, action: #selector(backBarButtonAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var topOffset: CGFloat = {
        let rectStatus = UIApplication.shared.statusBarFrame
        let rectNav = self.navigationController?.navigationBar.frame;
        let topOffset = ((rectNav?.size.height ?? 0.0) + rectStatus.size.height)
        return topOffset
    }()
    private var rightBarButtonItems: [UIBarButtonItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let count = self.navigationController?.viewControllers.count, count > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBarButton)
        }
        
        let fromColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.fromColor").value() as! UIColor
        let toColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.toColor").value() as! UIColor
        self.view.layer.addSublayer(kGradientLayer(colors: [fromColor.cgColor, toColor.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
        
        let image = UIImage(color: ThemeColorPicker(keyPath: "Global.NavigationBar.backgroundColor").value() as! UIColor, size: CGSize(width: 10, height: 10))
        let titleFont = ThemeFontPicker(stringLiteral: "Global.NavigationBar.textFont").value() as! UIFont
        let titleColor = ThemeColorPicker(keyPath: "Global.NavigationBar.textColor").value() as! UIColor
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: titleFont]
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            if navigationController?.navigationBar.isTranslucent ?? false {
                navigationBarAppearance.configureWithTransparentBackground()
            } else {
                navigationBarAppearance.configureWithOpaqueBackground()
            }
            
            navigationBarAppearance.theme_backgroundColor = "Global.NavigationBar.backgroundColor"
            navigationBarAppearance.theme_titleTextAttributes = ThemeStringAttributesPicker.pickerWithAttributes([titleTextAttributes])
            navigationBarAppearance.shadowImage = UIImage()
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
        else {
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
            self.navigationController?.navigationBar.theme_titleTextAttributes = ThemeStringAttributesPicker.pickerWithAttributes([titleTextAttributes])
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        self.setupNavigationBar()
        self.setupView()
        self.setupLayout()
        self.setupData()
        self.setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        SCSDKLogDebug("deinit: \(type(of: self))")
    }
}

extension SCBasicViewController {
    @objc func setupNavigationBar() { }
    @objc func setupView() { }
    @objc func setupLayout() { }
    @objc func setupData() { }
    @objc func setupObservers() { }
    
    @objc func backBarButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupRightBarButtonItem(title: String?, action: Selector, titleColor: ThemeColorPicker = "Global.NavigationRightItem.textColor", highlightedTitleColor: ThemeColorPicker? = "Global.NavigationRightItem.highlightedTextColor") {
        let btn = UIButton(title, titleColor: titleColor, font: "Global.NavigationRightItem.textFont", target: self, action: action, highlightedTitleColor: highlightedTitleColor, backgroundColor: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    func addRightBarButtonItem(image: ThemeImagePicker, action: Selector, imageEdgeInsets: UIEdgeInsets = UIEdgeInsets()) {
        let btn = UIButton(image: image, target: self, action: action, imageEdgeInsets: imageEdgeInsets)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.rightBarButtonItems.append(UIBarButtonItem(customView: btn))
        self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
    }
}
