//
//  CreateFeedViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 26.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class CreateFeedViewController : UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var feedDelegate : SetupFeedProtocol?
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var feedTitle: JVFloatLabeledTextField!
    @IBOutlet weak var feedInfo: JVFloatLabeledTextField!
    @IBOutlet weak var avatar: UIImageView!
    var selectedImage : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func selectAvatar(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let addFeed = UIAlertAction(title: "Take photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                
            }
        })
        let addFile = UIAlertAction(title: "From library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                
            }
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        // 4
        optionMenu.addAction(addFeed)
        optionMenu.addAction(addFile)
        optionMenu.addAction(cancelAction)
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectedImage = image
        avatar.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createFeed(sender: AnyObject) {
        let feedItem = PFObject(className:"feedItem")
        var imageFile : PFFile
        feedItem.setObject(PFObject(withoutDataWithClassName:"_User", objectId:PFUser.currentUser()?.valueForKey("objectId") as? String),forKey: "owner")
        feedItem.setObject(feedInfo.text!, forKey: "info")
        feedItem.setObject(feedTitle.text!, forKey: "title")
        imageFile = PFFile(data: UIImageJPEGRepresentation(selectedImage, 75)!)
        feedItem.setObject(imageFile, forKey: "mainImage")
       
        feedItem.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                let queryFeed = PFQuery(className: "feedItem")
                queryFeed.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
                     feedDelegate?.setupFeed(objects!)
                   
                }
            } else {
                // There was a problem, check error.description
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
