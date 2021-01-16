//
//  User.swift
//  ToDo List
//
//  Created by Artem Golubev on 11.01.2021.
//

import Foundation

class User {
    var login = ""
    var password = ""
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}
