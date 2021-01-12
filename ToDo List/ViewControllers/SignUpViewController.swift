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
        
        if loginTextField.text == nil
            || passwordTextField.text == nil
            || confirmPasswordTextField.text == nil {
            
            showAlert(title: "Not all fields are filled",
                      message: "Please, enter login and password")
            return
            
        } else if passwordTextField.text != confirmPasswordTextField.text {
            
            showAlert(title: "Password do not match",
                      message: "Please, enter correct login and password")
            return
            
        } else if StorageManager.shared.realm.objects(User.self)
            .filter("login = %@ AND password = %@",
                    loginTextField.text ?? "",
                    passwordTextField.text ?? "")
            .count > 0 {
            
            showAlert(title: "User already exists",
                      message: "Please, enter another correct login and password")
            return
        }
        
        let user = User(value: ["login": loginTextField.text, "password": passwordTextField.text])
        userSettings.set(user.login, forKey: "user")
        StorageManager.shared.save(user: user)
        performSegue(withIdentifier: "signup", sender: nil)
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
