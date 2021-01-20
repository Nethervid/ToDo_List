//
//  DBHelper.swift
//  ToDo List
//
//  Created by Artem Golubev on 13.01.2021.
//

import Foundation
import SQLite3

class DBHelper {
    
    private init() {
        db = openDatabase()
    }
    
    static let shared = DBHelper()
    let dbPath: String = "myDb3.sqlite"
    var db:OpaquePointer?

    private func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTables() {
        let createTableString = """
                                    CREATE TABLE IF NOT EXISTS "user"("login" TEXT PRIMARY KEY,"password" TEXT);
                                    CREATE TABLE IF NOT EXISTS "taskList" ("id" INTEGER,
                                                                           "name" TEXT,
                                                                           "creationDate" DATETIME,
                                                                           "user" TEXT,
                                                                           FOREIGN KEY("user") REFERENCES "user"("login"),
                                                                           PRIMARY KEY("id")
                                                                          );
                                    CREATE TABLE IF NOT EXISTS "task"("id" INTEGER PRIMARY KEY,
                                                                      "name" TEXT,
                                                                      "note" TEXT,
                                                                      "isComplete" INTEGER,
                                                                      "taskList" INTEGER,
                                                                      "creationDate" DATETIME,
                                                                      FOREIGN KEY(taskList) REFERENCES taskList(id));
                                """
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("error creating table: \(errmsg)")
            } else {
                print("tables are created.")
            }
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(user: User) {
        let login = user.login
        let password = user.password

        let insertStatementString = "INSERT INTO user (login, password) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (login as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (password as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func insert(taskListName: String) {
        guard let userName = UserDefaults.standard.string(forKey: "user") else { return }
        
        let insertStatementString = "INSERT INTO taskList (name, user, creationDate) VALUES (?, ?, Date('Now'));"
        var insertStatement: OpaquePointer? = nil
        let val = sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil)
        if val == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (taskListName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (userName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
            let err = sqlite3_errmsg(insertStatement)
            if let err = err {
                print(String(cString: err))
            }
        }
        
        sqlite3_finalize(insertStatement)

    }
    
    func insert(task: Task) {
        let insertStatementString = "INSERT INTO task(name, note, isComplete, taskList) VALUES (?, ?, 0, \(task.taskList));"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (task.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (task.note as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func getAllUsers() -> [User] {
        let queryStatementString = "SELECT * FROM user;"
        var queryStatement: OpaquePointer? = nil
        var users : [User] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let login = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let password = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                users.append(User(login: login, password: password))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return users
    }
    
    func getTaskLists(order: String? = nil) -> [TaskList] {
        guard let userName = UserDefaults.standard.string(forKey: "user") else { return [] }
        let queryStatementString = """
                                      SELECT id, name, user
                                      FROM taskList WHERE user = ?
                                      order by \(order ?? "id") ASC;
                                   """
        var queryStatement: OpaquePointer? = nil
        var taskLists : [TaskList] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (userName as NSString).utf8String, -1, nil)
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                taskLists.append(TaskList(id: Int(id), name: name, user: userName))
            }
        } else {
            print("SELECT statement could not be prepared")
            print(sqlite3_errmsg(queryStatement)!)
        }
        sqlite3_finalize(queryStatement)
        return taskLists
    }
    
    func getTasksByTaskList(taskListId: Int, condition: String? = nil) -> [Task] {
        let queryStatementString = """
                                      SELECT id, name, note, isComplete, creationDate
                                      FROM task
                                      WHERE taskList = ? \(condition != nil ? condition! : "");
                                   """
        var queryStatement: OpaquePointer? = nil
        var tasks : [Task] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(taskListId))
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let note = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let isComplete = sqlite3_column_int(queryStatement, 3)
                tasks.append(Task(id: Int(id), name: name, note: note, isComplete: Int(isComplete), taskList: taskListId))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tasks
    }
    
    func update(taskList: TaskList, newName: String) {
        let queryStatementString = """
                                      UPDATE taskList
                                      SET name = ?
                                      WHERE id = \(taskList.id);
                                   """
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (newName as NSString).utf8String, -1, nil)
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func update(task: Task, newName: String, newNote: String) {
        let queryStatementString = """
                                      UPDATE task
                                      SET name = ?, note = ?
                                      WHERE id = \(task.id);
                                   """
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (newName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (newNote as NSString).utf8String, -1, nil)
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func done(taskList: TaskList) {
        let queryStatementString = """
                                      UPDATE task
                                      SET isComplete = 1
                                      WHERE taskList = \(taskList.id);
                                   """
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func done(task: Task) {
        let statement = task.isComplete == 1 ? 0 : 1
        let queryStatementString = """
                                      UPDATE task
                                      SET isComplete = \(statement)
                                      WHERE id = \(task.id);
                                   """
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func deleteUser(login: String) {
        let deleteStatementString = "DELETE FROM user WHERE login = \(login);"
        delete(SQL: deleteStatementString)
    }
    
    func deleteByID(taskListID: Int) {
        let deleteStatementString = "DELETE FROM taskList WHERE id = \(taskListID);"
        delete(SQL: deleteStatementString)
    }
    
    func deleteByID(task: Int) {
        let deleteStatementString = "DELETE FROM task WHERE id = \(task);"
        delete(SQL: deleteStatementString)
    }
    
    private func delete(SQL: String) {
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, SQL, -1, &deleteStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
}
