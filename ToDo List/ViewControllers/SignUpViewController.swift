//
//  SignUpViewController.swift
//  ToDo List
//
//  Created by Artem Golubev on 11.01.2021.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let userSettings = UserDefaults.standard
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                  
    }
    
    @IBAction func signupPressed() {
       
        let login = loginTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        

    
        if password != nil && password != ""
            && login != nil && login != ""
            && confirmPassword != nil && confirmPassword != "" {
            
            let users = DBHelper.shared.getAllUsers()
            var hasUser = false
            for user in users {
                if user.login == login {
                    hasUser = true
                }
            }
            
            if password != confirmPassword {
                showAlert(title: "Passwordы do not match",
                          message: "Please, enter correct login and password")
                return
                
            } else if hasUser {
                showAlert(title: "User already exists",
                          message: "Please, enter another correct login and password")
                return
            }
            
            let user = User(login: loginTextField.text ?? "", password: passwordTextField.text ?? "")
            userSettings.set(user.login, forKey: "user")
            DBHelper.shared.insert(user: user)
            performSegue(withIdentifier: "signup", sender: nil)
        } else {
            showAlert(title: "Not all fields are filled",
                      message: "Please, enter correct data")
            return
        }
    }
    
}


// MARK: - Alert Controller
extension SignUpViewController {
    private func showAlert(title: String, message: String, textField: UITextField? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            textField?.text = nil
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
