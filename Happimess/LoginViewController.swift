//
//  LoginViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 26.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//
import UIKit

class LoginViewController : UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() == nil {
            self.navigationController!.performSegueWithIdentifier("authScreen", sender: self)
            
        } else {
            if (PFUser.currentUser()?.isAuthenticated() != nil) {
               gotoMain()
            } else {
                
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "authScreen" {
            (segue.destinationViewController as! ViewController).loginController = self
        }

    }
    
    func gotoMain() {
         self.navigationController!.performSegueWithIdentifier("mainScreen", sender: nil)
    }
}
