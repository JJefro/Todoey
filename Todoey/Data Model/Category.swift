//
//  Category.swift
//  Todoey
//
//  Created by Jevgenijs Jefrosinins on 27/04/2021.
//

import Foundation
import RealmSwift

class Category: Object {
    // dynamic variable - we can monitor for changes in this property while the app is running, during runtime.
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    let items = List<Item>()
}
