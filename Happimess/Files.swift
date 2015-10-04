//
//  Files.swift
//  Happimess
//
//  Created by Nikita Feshchun on 02.10.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit

class Files : UIViewController,UITableViewDataSource,UITableViewDelegate,UIDocumentPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
  
    @IBOutlet weak var tableview: UITableView!
    var menuItem : BTNavigationDropdownMenu!
   
    let imagePicker = UIImagePickerController()
    let sectionInsets = UIEdgeInsets(top: 18.0, left: 12.0, bottom: 0.0, right: 12.0)
    var allFiles : NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.registerNib(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCellID")
        tableview.registerNib(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "FileCellID")
        //        tableview.registerClass(FeedCell.classForCoder(), forCellReuseIdentifier: "FeedCellID")
        imagePicker.delegate = self
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let queryFiles = PFQuery(className: "uploadFile")
        queryFiles.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            self.allFiles.removeAllObjects()
            self.allFiles.addObjectsFromArray((objects?.reverse())!)
            self.tableview.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() == nil {
            self.navigationController!.performSegueWithIdentifier("authScreen", sender: nil)
            
        } else {
            if (PFUser.currentUser()?.isAuthenticated() != nil) {
                //                self.navigationController!.performSegueWithIdentifier("confirmProfileSegue", sender: nil)
            } else {
                
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FileCell! = tableView.dequeueReusableCellWithIdentifier("FileCellID") as? FileCell
        
        let file = allFiles[indexPath.row]
        let imageFile = file.valueForKey("avatar") as? PFFile
        if imageFile != nil {
            imageFile?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                let imageData = UIImage(data: data!)
                cell.mainimage.image = imageData
            })
        }
        //                cell.info?.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let currentDate = NSDate()
        let createdDate = file.valueForKey("createdAt") as! NSDate
        let distanceBetweenDates = currentDate.timeIntervalSinceDate(createdDate)
        let minutesInHour = 60 as Double
        let minutesBetween = distanceBetweenDates / minutesInHour;
        cell.info?.text = file.valueForKey("name") as? String
        var timeInfo : String = ""
        if (minutesBetween < 60) {
            timeInfo = String(format:"%.0f minutes ago", minutesBetween)
        }
        if (minutesBetween > 60 && minutesBetween < 1440) {
            timeInfo = String(format:"%.0f hours ago", minutesBetween / 60)
        }
        cell.title?.text = "Added by " + timeInfo
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //        if (segmentedControl.selectedSegmentIndex == 1) {
        //            if allFiles.count > 0 {
        //                return 1
        //            }
        //            return 0
        //        } else {
        return 1
        //        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //        if (segmentedControl.selectedSegmentIndex == 1) {
        //            if (section == 0) {
        //                return "TODAY"
        //            }
        //            return "YESTERDAY"
        //        } else {
        return ""
        //        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        if (segmentedControl.selectedSegmentIndex == 1) {
        //            return 20
        //        } else {
        return 0
        //        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        //        if (segmentedControl.selectedSegmentIndex == 1) {
        //            if (section == 0) {
        //                label.text = "  TODAY"
        //            }
        //            label.text = "  YESTERDAY"
        //            label.font = UIFont(name: "HelveticaNeue", size: 13.0)!
        //            label.textColor = UIColor(red: CGFloat(160.0/255.0), green: CGFloat(160.0/255.0), blue: CGFloat(160.0/255.0), alpha: CGFloat(1))
        //            label.backgroundColor = UIColor(red: CGFloat(242.0/255.0), green: CGFloat(242.0/255.0), blue: CGFloat(242.0/255.0), alpha: CGFloat(1))
        //        }
        return label
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let avatar = PFObject(className:"uploadFile")
        var imageFile : PFFile
        avatar.setObject(PFObject(withoutDataWithClassName:"_User", objectId:PFUser.currentUser()?.valueForKey("objectId") as? String),forKey: "owner")
        avatar.setObject("image", forKey: "name")
        imageFile = PFFile(data: UIImageJPEGRepresentation(image, 75)!)
        avatar.setObject(imageFile, forKey: "avatar")
        avatar.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                let queryFiles = PFQuery(className: "uploadFile")
                queryFiles.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
                    self.allFiles.removeAllObjects()
                    self.allFiles.addObjectsFromArray(objects!)
                    self.tableview.reloadData()
                }
            } else {
                // There was a problem, check error.description
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func documentPicker() {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.image"], inMode: UIDocumentPickerMode.Import)
        
        documentPicker.delegate = self
        
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
        self.presentViewController(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        let avatar = PFObject(className:"uploadFile")
        var file : PFFile
        avatar.setObject(PFObject(withoutDataWithClassName:"_User", objectId:PFUser.currentUser()?.valueForKey("objectId") as? String),forKey: "owner")
        avatar.setObject("image", forKey: "name")
        file = PFFile(data: NSData(contentsOfURL: url)!)
        avatar.setObject(file, forKey: "file")
        avatar.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                let queryFiles = PFQuery(className: "uploadFile")
                queryFiles.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
                    self.allFiles.removeAllObjects()
                    self.allFiles.addObjectsFromArray(objects!)
                    self.tableview.reloadData()
                }
            } else {
                // There was a problem, check error.description
            }
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
    }
    
    @IBAction func openProfile(sender: AnyObject) {
        self.navigationController!.performSegueWithIdentifier("confirmProfileSegue", sender: nil)
    }
    
    @IBAction func showMenu(sender: AnyObject) {
        
    }
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}