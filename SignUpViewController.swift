//
//  SignUpViewController.swift
//  app
//
//  Created by dhruv patel on 2/14/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    // Setting Up Button Styles
     func setUpElements() {
    // Hide the error label
    errorLabel.alpha = 0
    Utilities.styleTextField(firstNameTextField)
    Utilities.styleTextField(lastNameTextField)
    Utilities.styleTextField(emailTextField)
    Utilities.styleTextField(passwordTextField)
    Utilities.styleFilledButton(signUpButton)
    }
    
    func validateFields() -> String? {
        // Checked that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword)  == false  {
            //Password isnt secured enough
            return "Please make sure your password is at least 8 characters, contains a special number or charcater."
        }
        return nil
    }
    
    //-------------------------------------------------------------
    // When SignUp Button is Tapped
    //-------------------------------------------------------------
    
    @IBAction func signUpTapped(_ sender: Any) {
        // Validate the fields
        let error = validateFields()
            
        if error != nil {
            // wrong with the fiels
           showError(error!)
        }
        else {
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result,err) in
                
                // check for errors
                if  err != nil {
                    // there was an error
                    self.showError("Error Creating user")
                }
                else {
                    // user was created
                    let db = Firestore.firestore()
                    
                    //original code
//                    db.collection("users").addDocument(data: ["firstname": firstName, "lastname":lastName, "uid": result!.user.email ?? "User's email"]) { (error) in
//                        if error != nil {
                            // show error message
//                            self.showError("Error saving data ")
//                        }
//                    }
//                }
//            }
                    db.collection("users").document(result!.user.uid).setData(["firstname": firstName, "lastname":lastName, "uid": result!.user.uid])
                        
                }
            }
            
            // Transition to the home screen
            self.transitionToLogin()
                    }
    }
    
    //-------------------------------------------------------------
    // Show error if any while typing in text boxs
    //-------------------------------------------------------------
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    //-------------------------------------------------------------
    // Takes you to Welcome page
    //-------------------------------------------------------------
    func transitionToHome() {
      let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    //-------------------------------------------------------------
    // Takes you to Login page
    //-------------------------------------------------------------
    func transitionToLogin() {
      let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
        
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
    
    //-------------------------------------------------------------
    // Takes you to Login page if already Registered
    //-------------------------------------------------------------
    @IBAction func registeredTapped(_ sender: Any) {
        self.transitionToLogin()
    }
    
    
}
