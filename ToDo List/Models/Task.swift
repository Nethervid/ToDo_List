//
//  Task.swift
//  ToDo List
//
//  Created by Artem Golubev on 09.01.2021.
//

import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}
