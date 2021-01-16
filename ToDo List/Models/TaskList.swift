//
//  TaskList.swift
//  ToDo List
//
//  Created by Artem Golubev on 11.01.2021.
//

import Foundation

class TaskList {
    var id = 0
    var name = ""
    var creationDate = Date()
    var user = ""
    
    init(id: Int, name: String, user: String) {
        self.id = id
        self.name = name
        self.user = user
    }
}
