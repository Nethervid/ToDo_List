//
//  StorageManager.swift
//  ToDo List
//
//  Created by Artem Golubev on 09.01.2021.
//

/*import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    func save(taskList: TaskList) {
        write {
            let user = self.user()
            taskList.user = user
            realm.add(taskList)
        }
    }
    
    func save(task: Task, in taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func save(user: User) {
        write {
            realm.add(user)
        }
    }
    
    func delete(taskList: TaskList) {
        write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    func delete(task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func done(task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    func user() -> User? {
        let userName = UserDefaults.standard.string(forKey: "user")
        let user = realm.object(ofType: User.self, forPrimaryKey: userName)
        return user
    }
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
             completion()
            }
        } catch let error {
            print(error)
        }
    }
}
*/
