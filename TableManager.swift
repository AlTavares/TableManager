//
//  MXTableManager.swift
//  CrossFit Affiliates
//
//  Created by Henrique Morbin on 11/10/15.
//  Copyright © 2015 Morbix. All rights reserved.
//

import UIKit

private let defaultIdentifier = "TableManager_Default_Cell"

public class TableManager: NSObject {
    
    public weak var tableView: UITableView!
    
    public var sections = [Section]()
    public var visibleSections: [Section] {
        return sections.filter {
            $0.visible
        }
    }
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: defaultIdentifier)
    }
    
    // MARK: Methods
    
    public func reloadData(){
        tableView.reloadData()
    }
    
    public func row(atIndexPath indexPath: NSIndexPath) -> Row {
        let section = self.section(atIndex: indexPath.section)
        return section.row(atIndex: indexPath.row)
    }
    
    public func section(atIndex index: Int) -> Section {
        if visibleSections.count > index {
            return visibleSections[index]
        } else {
            let section = Section()
            sections.append(section)
            return section
        }
    }
    
}

// MARK: UITableViewDataSource

extension TableManager: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section(atIndex: section).visibleRows.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = self.row(atIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.identifier, forIndexPath: indexPath)
        
        row.configuration?(row: row, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        let section = self.section(atIndex: index)
        
        if let heightForHeader = section.heightForHeader {
            return CGFloat(heightForHeader(section: section, tableView: tableView, index: index))
        }
        
        return CGFloat(0.0)
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection index: Int) -> String? {
        let section = self.section(atIndex: index)
        
        if let titleForHeader = section.titleForHeader {
            return titleForHeader(section: section, tableView: tableView, index: index)
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        let section = self.section(atIndex: index)
        
        if let viewForHeader = section.viewForHeader {
            return viewForHeader(section: section, tableView: tableView, index: index)
        }
        
        return nil
    }
}

// MARK: UITableViewDelegate
    
extension TableManager: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = self.row(atIndexPath: indexPath)
        row.didSelect?(row: row, tableView: tableView, indexPath: indexPath)
    }
    
}


// MARK: Section Class

public class Section {
    
    public var visible = true
    public var object: AnyObject?
    public var rows = [Row]()
    public var visibleRows: [Row] {
        return rows.filter {
            $0.visible
        }
    }

    public var heightForHeader: HeightForHeader?
    public var titleForHeader: TitleForHeader?
    public var viewForHeader: ViewForHeader?
    
    public func row(atIndex index: Int) -> Row {
        if visibleRows.count > index {
            return visibleRows[index]
        } else {
            let row = Row(withIdentifier: defaultIdentifier)
            rows.append(row)
            return row
        }
    }
    
    // MARK: Header
    
    func setHeaderView(withDynamicText dynamicText: TitleForHeader) {
        titleForHeader = dynamicText
    }
    
    func setHeaderView(withStaticText staticText: String) {
        setHeaderView { (section, tableView, index) -> String in
            return staticText
        }
    }
    
    func setHeaderView(withDynamicView dynamicView: ViewForHeader) {
        viewForHeader = dynamicView
    }
    
    func setHeaderView(withStaticView staticView: UIView) {
        setHeaderView { (section, tableView, index) -> UIView in
            return staticView
        }
    }
    
    func setHeaderHeight(withDynamicHeight dynamicHeight: HeightForHeader) {
        heightForHeader = dynamicHeight
    }
    
    func setHeaderHeight(withStaticHeight staticHeight: Double) {
        setHeaderHeight { (section, tableView, index) -> Double in
            return staticHeight
        }
    }
    
    public typealias HeightForHeader = (section: Section, tableView: UITableView, index: Int) -> Double
    public typealias ViewForHeader = (section: Section, tableView: UITableView, index: Int) -> UIView
    public typealias TitleForHeader = (section: Section, tableView: UITableView, index: Int) -> String
    
}

// MARK: Row Class

public class Row {
    
    public let identifier: String
    public var visible = true
    public var object: AnyObject?
    public var configuration: ConfigurationBlock?
    public var didSelect: DidSelectBlock?
    
    public init(withIdentifier identifier: String){
        self.identifier = identifier
    }
    
    func setObject(object: AnyObject) {
        self.object = object
    }
    
    func setConfiguration(block: ConfigurationBlock) {
        self.configuration = block
    }
    
    func setDidSelect(block: DidSelectBlock) {
        self.didSelect = block
    }
    
    public typealias ConfigurationBlock = (row: Row, cell: UITableViewCell, indexPath: NSIndexPath) -> Void
    public typealias DidSelectBlock = (row: Row, tableView: UITableView, indexPath: NSIndexPath) -> Void
}
