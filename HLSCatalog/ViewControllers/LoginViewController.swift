//
//  LoginViewController.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/18/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: UI props
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // MARK: ViewModel
    fileprivate var loginViewModel: LoginViewModel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loginViewModel = LoginViewModel()
        loginViewModel.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        messageLabel.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if DEBUG
            loginTextField.text = "ac096"
            passwordTextField.text = "PassworD"
        #endif
    }

    // MARK: - Action
    @IBAction func signInPressed(_ sender: Any) {
        loginViewModel.logIn(email: loginTextField.text, password: passwordTextField.text)
    }
}

// MARK: - LoginViewModelDelegate
extension LoginViewController: LoginViewModelDelegate {
    func onCredentialsValidated(isValid: Bool, reason: String?) {
        messageLabel.alpha = isValid ? 0 : 1
        messageLabel.text = reason
    }
    
    func onLoginRequestFinished(success: Bool, errorMessage: String?) {
        messageLabel.alpha = success ? 0 : 1
        messageLabel.text = errorMessage
    }
}
