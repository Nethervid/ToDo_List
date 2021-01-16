//
//  Task.swift
//  ToDo List
//
//  Created by Artem Golubev on 09.01.2021.
//

import Foundation

class Task {
    var id = 0
    var name = ""
    var note = ""
    var creationDate = Date()
    var isComplete = 0
    var taskList = 0
    
    init(id: Int = 0, name: String, note: String, isComplete: Int = 0, taskList: Int) {
        self.id = id
        self.name = name
        self.note = note
        self.isComplete = isComplete
        self.taskList = taskList
    }
}
