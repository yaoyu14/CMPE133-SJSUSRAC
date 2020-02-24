//
//  CreateAccountViewController.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/27/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import Firebase


class CreateAccountViewController: UIViewController {

    // textfields and buttons
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var studentIDTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // hide error message as default
        errorLabel.alpha = 0
        setElements()
    }
    
    // set up textfields and buttons
    private func setElements() {
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(studentIDTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(confirmPassword)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // validate all text fields
    private func validateTextFields() -> String? {
        
        // check if textfields are all filled
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in required fields"
        }
        
        // check if the password met the requirements
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedConfirmPassword = confirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Utilities.isPasswordValid(cleanedPassword) {
            return "Please, make sure your password is at least 8 characters, containing letter, number and special character"
        }
        
        if cleanedPassword != cleanedConfirmPassword {
            return "Your passwords do not match!"
        }
        
        return nil
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        let error = validateTextFields()
        if error != nil {
            showErrorMessage(error!)
        }else {
            
            //create cleaned version of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let studentID = studentIDTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // create users
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                //check for error
                if err != nil{
                    self.showErrorMessage("Error occurs while creating user")
                } else {
                    
                    //user was created
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["first_name": firstName, "last_name": lastName, "studentID": studentID, "email": email, "password": password, "reservation": [String:String](), "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            
                            self.showErrorMessage("Error happened while saving user data")
                            
                        }
                    }
                }
            }
            
            //transition to home screen
            transitionToFirstPage()
        }
    }
    
    private func transitionToFirstPage() {
        let firstPageViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstPageViewController
        view.window?.makeKeyAndVisible()
    }
    
    private func showErrorMessage (_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    

}
