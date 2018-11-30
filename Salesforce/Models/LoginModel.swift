//
//  LoginModel.swift
//  Salesforce
//
//  Created by Bindu on 11/26/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class AuthenticationModel {
    
    func authenticate(email: String, passWord: String, completion: @escaping (MakanaRPTError?) -> Void)  {
        
        let loginQuery = LoginMutation(email: email, password: passWord)
        
        apollo.perform(mutation: loginQuery) { (result, error) in
            
            if let data = result?.data {
                KeychainWrapper.standard.set(data.login.token, forKey: "Bearer")
                completion(nil)
            }
            
            if let _ = result?.errors {
                completion(.invalidCred)
            }
            
        }
        
    }
    
    func logOut() {
        
        KeychainWrapper.standard.removeObject(forKey: "Bearer")
    }
}
