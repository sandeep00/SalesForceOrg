//
//  ViewController.swift
//  Salesforce
//
//  Created by Bindu on 11/15/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet fileprivate(set) weak var emailTextField: UITextField!
    
    @IBOutlet fileprivate(set) weak var passWordTextField: UITextField!
    
    @IBOutlet fileprivate(set) weak var loginButton: UIButton!

    var loginCompletionHandler: ((MakanaRPTError?) -> Void) = {(error) in
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
   
        if let error = error {

            let alertController = UIAlertController(title: "Login Error", message: error.errorDescription, preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            rootViewController?.present(alertController, animated: true, completion: nil)
        }
        else {

            let feed = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:                                            "feedBackTableViewController")

            let navController = UINavigationController(rootViewController: feed)

            rootViewController?.present(navController, animated: true, completion: nil)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        
        passWordTextField.delegate = self
        
        loginButton.isEnabled = false
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if let email = emailTextField.text,
            let password = passWordTextField.text {
            
            AuthenticationModel().authenticate(email:email, passWord: password, completion: loginCompletionHandler)

            emailTextField.text = ""
            
            passWordTextField.text = ""
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        
        if let email = emailTextField.text,
            let password = passWordTextField.text {
            loginButton.isEnabled = email.count > 0 && password.count > 0
        }
    }
}

