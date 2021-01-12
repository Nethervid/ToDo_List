//
//  AlertController.swift
//  ToDo List
//
//  Created by Artem Golubev on 08.01.2021.
//

import UIKit

class AlertController: UIAlertController {
    
    var doneButton = "Save"
    
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
        
        if taskList != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newList = self.textFields?.first?.text else { return }
            guard !newList.isEmpty else { return }
            completion(newList)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) {
        
        if task != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")

            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "New task"
            textField.text = task?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = task?.note
        }
    }
}
