//
//  ActionsViewController.swift
//  TableManager Example
//
//  Created by Luis Filipe Campani on 6/19/17.
//  Copyright © 2017 Morbix. All rights reserved.
//

import Foundation
import UIKit
import TableManager

class ActionsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

        alphabet.forEach { letter in
            let newSection = tableView.addSection()
                .setIndexTitle(letter)
                .setHeaderView(withStaticText: letter)
                .setHeaderHeight(withStaticHeight: 20)

            Fake.basicData().forEach { element in
                let row = newSection.addRow()
                let update = UITableViewRowAction(style: .normal, title: "Editar") { action, index in
                    print("Editar")
                }
                let delete = UITableViewRowAction(style: .default, title: "Excluir") { action, index in
                    print("Excluir")
                }
                row.setActions([delete, update])

                row.setConfiguration { _, cell, _ in
                    cell.textLabel?.text = element
                }
            }
        }
    }
}

extension ActionsViewController: Screen {
    static func screenTitle() -> String {
        return "Actions"
    }
}
