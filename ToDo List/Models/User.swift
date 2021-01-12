//
//  User.swift
//  ToDo List
//
//  Created by Artem Golubev on 11.01.2021.
//

import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override static func primaryKey() -> String? {
            return "login"
    }
}
