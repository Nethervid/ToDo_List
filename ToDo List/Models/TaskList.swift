//
//  TaskList.swift
//  ToDo List
//
//  Created by Artem Golubev on 11.01.2021.
//

import RealmSwift

class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    @objc dynamic var user: User?
    let tasks = List<Task>()
}
