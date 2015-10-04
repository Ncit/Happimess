//
//  ViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 13.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import ParseUI

class ViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginFB: FBSDKButton!
    var loginController : LoginViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if (FBSDKAccessToken.currentAccessToken() != nil)
        //        {
        ////            performSegueWithIdentifier("confirmProfileSegue", sender: self)
        //        } else {
        //
        //        }
        //        else
        //        {
        //            let loginView : FBSDKLoginButton = FBSDKLoginButton()
        //            self.view.addSubview(loginView)
        //            loginView.center = self.view.center
        //            loginView.readPermissions = ["public_profile", "email", "user_friends"]
        //            loginView.delegate = self
        //        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        if (FBSDKAccessToken.currentAccessToken() != nil)
        //        {
        //            performSegueWithIdentifier("confirmProfileSegue", sender: self)
        //        }
        //        var logInViewController = PFL
        //        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        //        logInViewController.delegate = self;
        //        [self presentViewController:logInViewController animated:YES completion:nil];
    }
    
    @IBAction func loginFB(sender: AnyObject) {
        let permissions = ["public_profile", "email","user_birthday","user_education_history"]
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.readPermissions = permissions
        
        loginView.delegate = self
        
        loginView.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                returnUserData()
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large),birthday, email,education"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                let userName : String = result.valueForKey("first_name") as! String
                let lastName : String = result.valueForKey("last_name") as! String
                let userEmail : String = result.valueForKey("email") as! String
                let avatarObject : NSDictionary = result.valueForKey("picture") as! NSDictionary
                let avatarDict : NSDictionary = avatarObject.valueForKey("data") as! NSDictionary
                let avatarUrl : String = avatarDict.valueForKey("url") as! String
                var imageFile : PFFile
                //                let education : NSArray = result.valueForKey("education") as! NSArray
                var profile = PFUser.currentUser()
                if profile == nil {
                    profile = PFUser()
                }
                profile!.setObject("1", forKey: "password")
                profile!.setObject(userName, forKey: "firstName")
                profile!.setObject(lastName, forKey: "lastName")
                profile!.setObject(userEmail, forKey: "email")
                profile!.setObject(userEmail, forKey: "username")
                if let url = NSURL(string: avatarUrl) {
                    if let dataImage = NSData(contentsOfURL: url) {
                        imageFile = PFFile(data:dataImage)
                        profile!.setObject(imageFile, forKey: "avatar")
                        
                    }
                    self.parseAuth(profile!)
                }
                
                //                profile.setObject(selectedDate, forKey: "birthday")
                //                profile.setObject(university.text!, forKey: "university")
                //                profile.setObject(department.text!, forKey: "department")
                
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func confirmScreen() {
        dismissViewControllerAnimated(true, completion: nil)
//        loginController.gotoMain()
    }
    
    func parseAuth(profile : PFUser) {
        let query = PFQuery()
        
        query.whereKey("username", equalTo: profile.objectForKey("email") as! String)
        query.getFirstObjectInBackgroundWithBlock { (object : PFObject?, error : NSError?) -> Void in
            if object != nil {
                PFUser.logInWithUsernameInBackground(profile.objectForKey("email") as! String, password:"1") {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                        self.confirmScreen()
                        // Do stuff after successful login.
                    } else {
                        // The login failed. Check error to see why.
                    }
                }
            }
            else
            {
                profile.signUpInBackgroundWithBlock({ (result: Bool, error : NSError?) -> Void in
//                    if result {
                        PFUser.logInWithUsernameInBackground(profile.objectForKey("email") as! String, password:"1") {
                            (user: PFUser?, error: NSError?) -> Void in
                            if user != nil {
                                self.confirmScreen()
                                // Do stuff after successful login.
                            } else {
                                // The login failed. Check error to see why.
                            }
                        }
//                    }
                    
                })
            }
        }
    }
}

