//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    var errorMessage = "Please try again"
    var signupActive = true
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registeredText: UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        // Error checking if nothing happens in either in username or password
        if username.text == "" || password.text == "" {
            displayAlert("Error in form", message: "Please enter a username and password")
            
        } else {
            // Add spin
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            if signupActive == true {
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                user.signUpInBackgroundWithBlock {
                    (success, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if let error = error {
                        let errorString = error.userInfo["error"] as? String
                        // Show the errorString somewhere and let the user try again.
                        self.errorMessage = errorString!
                        self.displayAlert("Failed SignUp", message: self.errorMessage)
                    } else {
                        // successful
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    }
                }
                
            } else {
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if user != nil {
                        // Do stuff after successful login.
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        // The login failed. Check error to see why.
                        if let error = error {
                            let errorString = error.userInfo["error"] as? String
                            // Show the errorString somewhere and let the user try again.
                            self.errorMessage = errorString!
                            self.displayAlert("Failed Login", message: self.errorMessage)
                        }
                    }
                }
            }
            
        }
    }
    
    
    @IBAction func logIn(sender: AnyObject) {
        if signupActive == true {
            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
            registeredText.text = "Not registered?"
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            signupActive = false
        } else {
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            registeredText.text = "Already registered?"
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            signupActive = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Check if the current user is here and if it is it will be automatically into the user table
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}