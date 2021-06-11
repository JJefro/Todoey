//
//  Items.swift
//  Todoey
//
//  Created by Jevgenijs Jefrosinins on 27/04/2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
//    @objc dynamic var currentDate: String = ""
//    @objc dynamic var date: Date? {
//            let dateFormatter = DateFormatter()
//        let date: Date? = dateFormatter.date(from: "dd/MM/yyyy HH:mm:ss")
//        return date
//    }
    //And finally we specify the inverse relationship that links each item back to a parentCategory, and we specify(указывать) the type of the destination of the link, and we also specify the property name of the inverse relationship, and that relates to this property.
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
