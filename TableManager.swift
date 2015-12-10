//
//  MXTableManager.swift
//  CrossFit Affiliates
//
//  Created by Henrique Morbin on 11/10/15.
//  Copyright © 2015 Morbix. All rights reserved.
//

import UIKit

class TableManager: NSObject {
    
    let tableView : UITableView
    var sections = [Section]()
    var visibleSections :[Section] {
        return sections.filter({ (section) -> Bool in
            return section.visible
        })
    }
    var stateRows : StateRowsTuple?
    var state : ScreenState = .None {
        didSet {
            self.tableView.reloadData()
        }
    }
    static let kDefaultIdentifier = "TableManager_Default_Cell"
    
    init(tableView : UITableView){
        self.tableView = tableView

        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: TableManager.kDefaultIdentifier)
    }
    
    func reloadData(){
        tableView.reloadData()
    }
    
    func rowForIndexPath(indexPath: NSIndexPath) -> Row{
        if let stateRows =  stateRows{
            switch state {
            case .Loading:
                return stateRows.loading
            case .Empty:
                return stateRows.empty
            case .Error:
                return stateRows.error
            default:
                return visibleSections[indexPath.section].visibleRows[indexPath.row]
            }
        }else{
            return visibleSections[indexPath.section].visibleRows[indexPath.row]
        }
    }
    
    func sectionForIndex(index: Int) -> Section {
        if visibleSections.count > index{
            return visibleSections[index]
        }else{
            return Section()
        }
    }
    
    static func getDefaultStateRows() -> StateRowsTuple{
        let handler :ConfigureCellBlock = { (object, cell, indexPath) -> Void in
            if let object = object as? String {
                cell.textLabel?.text = object
                cell.textLabel?.textAlignment = .Center
                cell.selectionStyle = .None
            }
        }
        let loadingRow = Row(identifier: TableManager.kDefaultIdentifier, object: "Loading...", configureCell: handler)
        let emptyRow = Row(identifier: TableManager.kDefaultIdentifier, object: "Empty", configureCell: handler)
        let errorRow = Row(identifier: TableManager.kDefaultIdentifier, object: "Error", configureCell: handler)
        
        return (loadingRow, emptyRow, errorRow)
    }
}

// MARK: UITableViewDelegate and UITableViewDataSource
extension TableManager : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if stateRows != nil && state != .None {
            return 1
        }else{
            return visibleSections.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stateRows != nil && state != .None {
            return 1
        }else{
            return visibleSections.count > section ? visibleSections[section].visibleRows.count : 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let row = visibleSections[indexPath.section].visibleRows[indexPath.row]
        let row = rowForIndexPath(indexPath)

        if let cellForRowAtIndexPath = row.cellForRowAtIndexPath {
            return cellForRowAtIndexPath(row: row, tableView: tableView, indexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(row.identifier, forIndexPath: indexPath)
        
        if let configureCell = row.configureCell {
            configureCell(object: row.object, cell: cell, indexPath: indexPath)
        }else if let cell = cell as? ConfigureCell {
            cell.configureCell(row.object, target: self, indexPath: indexPath)
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        
        let section = sectionForIndex(index)
        
        if let heightForHeaderInSection = section.heightForHeaderInSection {
            return heightForHeaderInSection(section: section, tableView: tableView, index: index)
        }
        
        return CGFloat(section.heightForStaticHeader)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection index: Int) -> String? {
        let section = sectionForIndex(index)
        
        if let titleForHeaderInSection = section.titleForHeaderInSection {
            return titleForHeaderInSection(section: section, tableView: tableView, index: index)
        }
        
        if let titleForStaticHeader = section.titleForStaticHeader {
            return titleForStaticHeader
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        let section = sectionForIndex(index)
        
        if let viewForHeaderInSection = section.viewForHeaderInSection {
            return viewForHeaderInSection(section: section, tableView: tableView, index: index)
        }
        
        if let viewForStaticHeader = section.viewForStaticHeader {
            return viewForStaticHeader
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = rowForIndexPath(indexPath)
        
        if let didSelectRowAtIndexPath = row.didSelectRowAtIndexPath {
            didSelectRowAtIndexPath(row: row, tableView: tableView, indexPath: indexPath)
        }
    }
}


// MARK: Classes
class Section: NSObject {
    var visible = true
    var rows = [Row]()
    var visibleRows :[Row] {
        return rows.filter({ (row) -> Bool in
            return row.visible
        })
    }
    var heightForStaticHeader = 0.0
    var heightForHeaderInSection : HeightForHeaderInSectionBlock?
    var titleForStaticHeader : String?
    var titleForHeaderInSection : TitleForHeaderInSectionBlock?
    var viewForStaticHeader : UIView?
    var viewForHeaderInSection : ViewForHeaderInSectionBlock?
}

class Row: NSObject {
    let identifier : String
    var visible = true
    var object : AnyObject?
    var configureCell : (ConfigureCellBlock)?
    var cellForRowAtIndexPath : (CellForRowAtIndexPathBlock)?
    var didSelectRowAtIndexPath : (DidSelectRowAtIndexPath)?
    
    init(identifier: String){
        self.identifier = identifier
    }
    

    convenience init(identifier:String, object:AnyObject?, configureCell:ConfigureCellBlock?) {
        self.init(identifier: identifier)
        
        self.object = object
        self.configureCell = configureCell
    }
    
}

// MARK: Type Alias
typealias StateRowsTuple = (loading: Row, empty: Row, error: Row)
typealias ConfigureCellBlock = (object:Any?, cell:UITableViewCell, indexPath: NSIndexPath) -> Void
typealias CellForRowAtIndexPathBlock = (row: Row, tableView: UITableView,  indexPath: NSIndexPath) -> UITableViewCell
typealias HeightForHeaderInSectionBlock = (section: Section, tableView: UITableView, index: Int) -> CGFloat
typealias ViewForHeaderInSectionBlock = (section: Section, tableView: UITableView, index: Int) -> UIView
typealias TitleForHeaderInSectionBlock = (section: Section, tableView: UITableView, index: Int) -> String
typealias DidSelectRowAtIndexPath = (row: Row, tableView: UITableView, indexPath: NSIndexPath) -> Void

// MARK: ScreenState
enum ScreenState : String {
    case None    = ""
    case Loading = "Loading..."
    case Empty   = "No Data"
    case Error   = "Error"
    
    mutating func setByResultsAndErrors(results : [AnyObject], errors: [NSError]){
        if (results.count > 0) {
            self = .None
        }else if (errors.count > 0) {
            self = .Error
        }else {
            self = .Empty
        }
    }
    
    mutating func setByResultsAndError(results : [AnyObject], error: NSError?){
        if (results.count > 0) {
            self = .None
        }else if (error != nil) {
            self = .Error
        }else {
            self = .Empty
        }
    }
}

// MARK: Protocols
protocol ConfigureCell {
    func configureCell(object: Any?, target: AnyObject?, indexPath: NSIndexPath?)
}