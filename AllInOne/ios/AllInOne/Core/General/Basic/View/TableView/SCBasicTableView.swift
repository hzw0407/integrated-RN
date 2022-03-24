//
//  SCBasicTableView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import SwiftTheme
import sqlcipher

class SCBasicTableView: UITableView {
    
    private (set) var list: [[Any]] = []
    private var headerList: [Any?] = []
    private var cellIdentify: String = ""
    private var headerIdentify: String = ""
    private var footerIdentify: String = ""
    private weak var cellDelegate: AnyObject?
    
    private var sectionTitles: [String]?
    
    private var subCellIdentifys: [String] = []
    private var subCellSections: [Int] = []
    private var subCellDelegates: [AnyObject?] = []
    
    private var sectionHeaderHeights: [CGFloat?] = []
    private var isAutoHeaderHeight: Bool = false
    
    public var didSelectBlock: ((IndexPath) -> Void)?
    private var didScrollBlock: (() -> Void)?
    private var didDeleteBlock: ((IndexPath) -> Void)?
    
    private var notEditingIndexPath: IndexPath?
    
    private lazy var emptyView: SCBasicListEmptyView = SCBasicListEmptyView()
    
    private var hasEmptyView: Bool = false
    
    var canDeleteEdit: Bool = false
    
    init(cellClass: AnyClass, cellIdendify: String, rowHeight: CGFloat?, cellDelegate: AnyObject? = nil, style: Style = .plain, hasEmptyView: Bool = false, didSelectHandle: ((IndexPath) -> Void)? = nil) {
        super.init(frame: .zero, style: style)
        self.backgroundColor = .clear
        self.sectionHeaderHeight = 0
        self.sectionFooterHeight = 0
        self.separatorStyle = .none
        self.dataSource = self
        self.delegate = self
        if rowHeight != nil {
            self.rowHeight = rowHeight!
        }
        else {
            self.estimatedRowHeight = 50
            self.rowHeight = UITableView.automaticDimension
        }
        self.register(cellClass, forCellReuseIdentifier: cellIdendify)
        
        self.cellIdentify = cellIdendify
        self.didSelectBlock = didSelectHandle
        self.cellDelegate = cellDelegate
        
        if hasEmptyView {
            self.hasEmptyView = true
            self.addSubview(self.emptyView)
        }
    }
    
    func register(cell cellClass: AnyClass?, idendify: String, section: Int, cellDelegate: AnyObject? = nil) {
        self.register(cellClass, forCellReuseIdentifier: idendify)
        self.subCellIdentifys.append(idendify)
        self.subCellSections.append(section)
        self.subCellDelegates.append(cellDelegate)
    }
    
    func register(header aClass: AnyClass, idendify: String, height: CGFloat?) {
        if height != nil {
            self.sectionHeaderHeight = height!
        }
        else {
            self.isAutoHeaderHeight = true
            self.estimatedSectionHeaderHeight = 50
            self.sectionHeaderHeight = UITableView.automaticDimension
        }
        self.register(aClass, forHeaderFooterViewReuseIdentifier: idendify)
        self.headerIdentify = idendify
    }
    
    func register(footer aClass: AnyClass, idendify: String, height: CGFloat?) {
        if height != nil {
            self.sectionFooterHeight = height!
        }
        else {
            self.estimatedSectionFooterHeight = 50
            self.sectionFooterHeight = UITableView.automaticDimension
        }
        self.register(aClass, forHeaderFooterViewReuseIdentifier: idendify)
        self.footerIdentify = idendify
    }
    
    func set(headerHeights heights: [CGFloat?]) {
        self.sectionHeaderHeights = heights
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(list: [[Any]], headerList: [Any?] = []) {
        self.list = list
        self.headerList = headerList
        self.reloadData()
    }
    
    func set(sectionTitles: [String]?, color: ThemeColorPicker? = nil) {
        self.sectionTitles = sectionTitles
        self.theme_sectionIndexColor = color
        self.reloadData()
    }
    
    func add(didScrollHandle: (() -> Void)?) {
        self.didScrollBlock = didScrollHandle
    }
    
    func set(didDeleteHandle: ((IndexPath) -> Void)?) {
        self.didDeleteBlock = didDeleteHandle
    }
    
    func set(editing: Bool, notEditingIndexPath: IndexPath?) {
        self.isEditing = editing
        self.notEditingIndexPath = notEditingIndexPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.canDeleteEdit {
            self.configSwipeButtons()
        }
    }
}

extension SCBasicTableView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.list[indexPath.section][indexPath.row]
        if self.subCellIdentifys.count > 0 && self.subCellIdentifys.count == self.subCellSections.count {
            for (i, section) in self.subCellSections.enumerated() {
                if section == indexPath.section {
                    let id = self.subCellIdentifys[i]
                    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
                    cell.set(model: model)
                    cell.set(delegate: self.subCellDelegates[i])
                    return cell
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentify, for: indexPath)
        cell.set(model: model)
        cell.set(delegate: self.cellDelegate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.headerIdentify.count == 0 {
            return nil
        }
        if section < self.sectionHeaderHeights.count {
            if let height = self.sectionHeaderHeights[section], height > 0 {
                return nil
            }
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerIdentify)
        if self.headerList.count > section {
            let model = self.headerList[section]
            view?.set(model: model)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.footerIdentify.count == 0 {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.footerIdentify)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectBlock?(indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollBlock?()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < self.sectionHeaderHeights.count {
            if let height = self.sectionHeaderHeights[section] {
                return height
            }
            return UITableView.automaticDimension
        }
        if self.isAutoHeaderHeight {
            return UITableView.automaticDimension
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.canDeleteEdit {
            return true
        }
        if self.notEditingIndexPath == indexPath {
            return false
        }
        else {
            return self.isEditing
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.notEditingIndexPath == indexPath {
            return false
        }
        if self.isEditing {
            self.configMoveButtons()
        }
        return self.isEditing
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceItem = self.list[sourceIndexPath.section][sourceIndexPath.row]
        self.list[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        self.list[destinationIndexPath.section].insert(sourceItem, at: destinationIndexPath.row)
        self.configMoveButtons()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.canDeleteEdit {
            return .delete
        }
        if self.notEditingIndexPath == indexPath {
            return .none
        }
        else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.didDeleteBlock?(indexPath)
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "    ") { [weak self] _, _, _ in
            self?.configSwipeButtons()
            self?.didDeleteBlock?(indexPath)
        }
        deleteAction.backgroundColor = .clear
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        self.setNeedsLayout()
        return config
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .destructive, title: nil) { [weak self] _, _ in
            self?.configSwipeButtons()
            self?.didDeleteBlock?(indexPath)
        }
        action.backgroundColor = .clear
        return [action]
    }
}

extension SCBasicTableView {
    private func configMoveButtons() {
        for subview in self.subviews {
            if let aClass = NSClassFromString("UITableViewCell"), subview.isKind(of: aClass) && subview.subviews.count >= 1 {
                for view in subview.subviews {
                    let className = NSStringFromClass(view.classForCoder)
                    if (className as NSString).range(of: "Reorder").location != NSNotFound {
                        for subView in view.subviews {
                            if subView.isKind(of: UIImageView.self) {
                                (subView as? UIImageView)?.theme_image = "HomePage.FamilyListController.RoomListController.ItemCell.sortImage"
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func configSwipeButtons(indexPath: IndexPath? = nil) {
        if #available(iOS 13.0, *) {
            for subview in self.subviews {
                if let aClass = NSClassFromString("_UITableViewCellSwipeContainerView"), subview.isKind(of: aClass) && subview.subviews.count >= 1 {
                    for sub in subview.subviews {
                        if let aClass = NSClassFromString("UISwipeActionPullView"), sub.isKind(of: aClass) && sub.subviews.count >= 1 {
                            let readView = subview.subviews[0].subviews.first
                            self.setup(rowActionView: readView)
                            break
                        }
                    }
                }
            }
        }
        else {
            if #available(iOS 11.0, *) {
                for subview in self.subviews {
                    if let aClass = NSClassFromString("UISwipeActionPullView"), subview.isKind(of: aClass) && subview.subviews.count >= 1 {
                        let readView = subview.subviews[0]
                        self.setup(rowActionView: readView)
                    }
                }
            }
            else {
                if let indexPath = indexPath, let cell = self.cellForRow(at: indexPath) {
                    for subview in cell.subviews {
                        if let aClass = NSClassFromString("UITableViewCellDeleteConfirmationView"), subview.isKind(of: aClass) && subview.subviews.count >= 1 {
                            let readView = subview
                            self.setup(rowActionView: readView)
                        }
                    }
                }
            }
        }
    }
    
    private func setup(rowActionView: UIView?) {
        guard let button = rowActionView as? UIButton else { return }
        button.theme_setImage("Global.ItemCell.deleteButton.image", forState: .normal)
        button.theme_backgroundColor = "Global.ItemCell.deleteButton.backgroundColor"
    }
}

extension SCBasicTableView {
    override func reloadData() {
        super.reloadData()
        if self.hasEmptyView {
            if self.list.count == 0 || self.list[0].count == 0 {
                self.addSubview(self.emptyView)
                self.emptyView.frame = CGRect(x: 0, y: 60, width: self.bounds.width, height: self.bounds.height - 60)
                self.emptyView.setNeedsUpdateConstraints()
                self.emptyView.isHidden = false
            }
            else {
                self.emptyView.isHidden = true
                self.emptyView.removeFromSuperview()
            }
        }
    }
}
