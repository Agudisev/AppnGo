//
//  LoginViewController.swift
//  app
//
//  Created by dhruv patel on 2/14/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //-------------------------------------------------------------
        setUpElements()
    }
 
     func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // style the elements
        Utilities.styleTextField(EmailTextField)
        Utilities.styleTextField(PasswordTextField)
        Utilities.styleFilledButton(loginButton)
   
    }
    
    //-------------------------------------------------------------
    // When Login Button is Tapped
    //-------------------------------------------------------------
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // Validate text fields
        
        // Create cleaned versions of the text field
        let email = EmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                // couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
                
            }
        }
    }
    
      //-------------------------------------------------------------
      // Takes you to SignUp page
      //-------------------------------------------------------------
      func transitionToSignUp() {
        let signUpViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.signUpViewController) as? SignUpViewController
          
          view.window?.rootViewController = signUpViewController
          view.window?.makeKeyAndVisible()
      }
    
    //-------------------------------------------------------------
    // Takes you to Login page if already Registered
    //-------------------------------------------------------------
    @IBAction func signUpTapped(_ sender: Any) {
        self.transitionToSignUp()
    }
    
    
    
    
}
