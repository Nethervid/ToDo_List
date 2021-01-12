//
//  ViewController.swift
//  ToDo List
//
//  Created by Artem Golubev on 08.01.2021.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let user = StorageManager.shared.user()
        taskLists = StorageManager.shared.realm.objects(TaskList.self).filter("user = %@", user ?? "")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
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
            ? taskLists.sorted(byKeyPath: "name")
            : taskLists.sorted(byKeyPath: "date")
        
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
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            StorageManager.shared.done(taskList: taskList)
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
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        present(alert, animated: true)
    }
}

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTask = taskList.tasks.filter("isComplete = false")
        let completedTask = taskList.tasks.filter("isComplete = true")
        
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
