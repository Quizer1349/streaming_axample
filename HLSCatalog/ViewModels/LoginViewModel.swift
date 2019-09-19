//
//  LoginViewModel.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: class {
    func onCredentialsValidated(isValid: Bool, reason: String?)
    func onLoginRequestFinished(success: Bool, errorMessage: String?)
}

struct LoginViewModel {
    weak var delegate: LoginViewModelDelegate?
    
    public func logIn(email: String?, password: String?) {
        let isValidCredentials = self.validateCredentials(email, password)
        
        let validationReason = isValidCredentials
            ? nil
            : NSLocalizedString("Credentials are invalid! Please, check email and password.", comment: "Errors")
        self.delegate?.onCredentialsValidated(isValid: isValidCredentials,
                                              reason: validationReason)

        if  isValidCredentials {
            let requestParams = ["email": email ?? "", "password": password ?? ""]
            Networking.request(endpoint: Endpoints.login, params: requestParams) { (result: Result<UserModel, NetError>) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.handleSuccess(response)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.handleError(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    fileprivate func validateCredentials(_ email: String?, _ password: String?) -> Bool {
        guard let email = email, email.isEmpty == false,
            let password = password, password.isEmpty == false else {
                return false
        }
        return true
    }
    
    fileprivate func handleSuccess(_ user: UserModel) {
        guard let token = user.authToken else {
            return
        }
        AuthManager.shared.loginUserWithToken(token: token)
        self.delegate?.onLoginRequestFinished(success: true, errorMessage: nil)
        Router.switchToFlow(.main)
    }
    
    fileprivate func handleError(_ error: NetError) {
        var errorMessage = NSLocalizedString("Something went wrong! Please, contact us.", comment: "Errors")
        if case NetError.serverError(let message) = error {
            errorMessage = message
        }
        self.delegate?.onLoginRequestFinished(success: false, errorMessage: errorMessage)
    }
}
