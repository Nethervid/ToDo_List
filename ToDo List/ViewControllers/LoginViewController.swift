//
//  LoginViewController.swift
//  ToDo List
//
//  Created by Artem Golubev on 10.01.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let userSettings = UserDefaults.standard
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DBHelper.shared.createTables()
    }
    
    @IBAction func logoutAction (_ sender: UIStoryboardSegue) {
        loginTextField.text = nil
        passwordTextField.text = nil
        
        userSettings.removeSuite(named: "user")
    }
    
    @IBAction func loginPressed() {

        let users = DBHelper.shared.getAllUsers()
        var user: User? = nil
        for userFromArray in users {
            if userFromArray.login == loginTextField.text
                && userFromArray.password == passwordTextField.text {
                user = userFromArray
            }
        }
        
        if user == nil {
            showAlert(title: "Invalid login or password",
                      message: "Please, enter correct login and password",
                      textField: passwordTextField)
            return
        }
        
        userSettings.set(user?.login, forKey: "user")
        performSegue(withIdentifier: "login", sender: nil)
    }
    
}


// MARK: Text Field Delegate
extension LoginViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            loginPressed()
        }
        return true
    }
}

// MARK: - Alert Controller
extension LoginViewController {
    private func showAlert(title: String, message: String, textField: UITextField? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            textField?.text = nil
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
