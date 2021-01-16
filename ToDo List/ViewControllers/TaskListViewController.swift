//
//  ViewController.swift
//  ToDo List
//
//  Created by Artem Golubev on 08.01.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    var taskLists: [TaskList]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTaskLists()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    private func updateTaskLists() {
        taskLists = DBHelper.shared.getTaskLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? DBHelper.shared.getTaskLists(order: "name")
            : DBHelper.shared.getTaskLists(order: "creationDate")
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            DBHelper.shared.deleteByID(taskListID: taskList.id)
            self.taskLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: taskList) {
                
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            DBHelper.shared.done(taskList: taskList)
            self.updateTaskLists()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.taskList = taskList
    }
}

extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        
        let title = taskList != nil ? "Edit List" : "New List"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.action(with: taskList) { newValue in
            
            if let taskList = taskList, let completion = completion {
                DBHelper.shared.update(taskList: taskList, newName: newValue)
                self.updateTaskLists()
                completion()
            } else {
                
                DBHelper.shared.insert(taskListName: newValue)
                let newTaskList = DBHelper.shared.getTaskLists().last
                
                if let newTaskList = newTaskList {
                    self.taskLists.append(newTaskList)
                    let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                    self.tableView.insertRows(at: [rowIndex], with: .automatic)
                }
                
            }
        }
        present(alert, animated: true)
    }
}

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTask = DBHelper.shared.getTasksByTaskList(taskListId: taskList.id, condition: "AND isComplete = 0")
        let completedTask = DBHelper.shared.getTasksByTaskList(taskListId: taskList.id, condition: "AND isComplete = 1")
        
        textLabel?.text = taskList.name
        
        if !currentTask.isEmpty {
            detailTextLabel?.text = "\(currentTask.count)"
            accessoryType = .none
        } else if !completedTask.isEmpty {
            detailTextLabel?.text = nil
            accessoryType = .checkmark
        } else {
            detailTextLabel?.text = "0"
            accessoryType = .none
        }
    }
}
