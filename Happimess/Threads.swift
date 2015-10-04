//
//  Threads.swift
//  Happimess
//
//  Created by Nikita Feshchun on 22.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit
import DynamicBlurView
import SABlurImageView

class Threads : UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIDocumentPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SetupFeedProtocol {
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var top_bg: SABlurImageView!
    @IBOutlet weak var menuPlaceholder: UIView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var membersCollection: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    
    let kTableHeight: CGFloat = 64.0
    
    let items = ["Active group", "Files", "Members"]
    let imagePicker = UIImagePickerController()
    let sectionInsets = UIEdgeInsets(top: 18.0, left: 12.0, bottom: 0.0, right: 12.0)
    var allObjects : NSMutableArray = []
    var allFiles : NSMutableArray = []
    var feeds : NSMutableArray = []
    var selectedSegmentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        top_bg.addBlurEffect(30, times: 3)
        tableview.registerNib(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCellID")
        tableview.registerNib(UINib(nibName: "FileCell", bundle: nil), forCellReuseIdentifier: "FileCellID")
        membersCollection.registerNib(UINib(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: "MemberCellID")
        //        tableview.registerClass(FeedCell.classForCoder(), forCellReuseIdentifier: "FeedCellID")
        imagePicker.delegate = self
        let menuItem = BTNavigationDropdownMenu(title: items.first!, items: items)
        //        self.navigationItem.titleView = menuView
        menuItem.cellTextLabelColor = UIColor.whiteColor()
        menuItem.cellSeparatorColor = UIColor.clearColor()
           menuItem.didShow = {(indexPath: Int) -> () in
            self.placeholderView.alpha = 1.0
        }
        menuItem.didHide = {(indexPath: Int) -> () in
            self.placeholderView.alpha = 0
        }
        menuItem.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
//            self.selectedSegmentIndex = indexPath
//            if (self.selectedSegmentIndex == 2) {
//                self.membersCollection.alpha = 1.0
//            } else {
//                self.membersCollection.alpha = 0.0
//            }
//            self.tableview.reloadData()
                        if (indexPath == 1) {
                            self.performSegueWithIdentifier("filesSegue", sender: nil)
                        }
                        if (indexPath == 2) {
                            self.performSegueWithIdentifier("membersSegue", sender: nil)
                        }
        }
        
        menuPlaceholder.addSubview(menuItem)
        let blurView = DynamicBlurView(frame: top_bg.bounds)
        blurView.blurRadius = 10
        //        top_bg.addSubview(blurView)
        //     applyBlurEffect(UIImage(named: "top_bg.png")!)
    }
    func applyBlurEffect(image: UIImage){
        var imageToBlur = CIImage(image: image)
        var blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        var resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        self.top_bg.image = blurredImage
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let queryMembers = PFQuery(className: "_User")
        queryMembers.whereKey("email", notEqualTo: (PFUser.currentUser()?.valueForKey("email"))!)
        queryMembers.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            if (objects != nil) {
                self.allObjects.removeAllObjects()
                self.allObjects.addObjectsFromArray(objects!)
                self.membersCollection.reloadData()
            }
        }
        let queryFiles = PFQuery(className: "uploadFile")
        queryFiles.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            if (objects != nil) {
                self.allFiles.removeAllObjects()
                
                self.allFiles.addObjectsFromArray((objects?.reverse())!)
                self.tableview.reloadData()
            }
        }
        let queryFeed = PFQuery(className: "feedItem")
        queryFeed.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            if (objects != nil) {
                self.feeds.removeAllObjects()
                self.feeds.addObjectsFromArray(objects!)
                self.tableview.reloadData()
            }
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
        if (selectedSegmentIndex == 1) {
            return allFiles.count
        } else {
            return feeds.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        
        if (selectedSegmentIndex == 0) {
            let cell: FeedCell! = tableView.dequeueReusableCellWithIdentifier("FeedCellID") as? FeedCell
            let feedItem = feeds[indexPath.row]
            cell.info?.text = feedItem.valueForKey("info") as? String
            cell.title?.text = feedItem.valueForKey("title") as? String
            let imageFile = feedItem.valueForKey("mainImage") as? PFFile
            if imageFile != nil {
                imageFile?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                    let imageData = UIImage(data: data!)
                    cell.mainimage.image = imageData
                })
            }
            var count : NSNumber
            if (feedItem.valueForKey("counter") != nil) {
                count = feedItem.valueForKey("counter") as! NSNumber
            } else {
                count = 0
            }
            if (count.intValue > 0) {
                cell.counter.text = "\(count.intValue)"
                
            } else {
                cell.counter.alpha = 0
                
            }
            let owner = feedItem.valueForKey("owner") as? PFUser
            
            let queryOwner = PFQuery(className:"_User")
            queryOwner.getObjectInBackgroundWithId(owner?.valueForKey("objectId") as! String) {
                (object: PFObject?, error: NSError?) -> Void in
                let avatar = object!.valueForKey("avatar") as? PFFile
                if avatar != nil {
                    avatar?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                        let imageData = UIImage(data: data!)
                        cell.avatar.image = imageData
                    })
                }
            }
            
            
            cell.avatar.layer.borderWidth = 2
            cell.avatar.layer.masksToBounds = false
            cell.avatar.layer.borderColor = UIColor(red: CGFloat(245.0/255.0), green: CGFloat(245.0/255.0), blue: CGFloat(245.0/255.0), alpha: CGFloat(1.0)).CGColor
            cell.avatar.layer.cornerRadius = cell.avatar.frame.height/2
            cell.avatar.clipsToBounds = true
            
            cell.mainimage.layer.borderWidth = 2
            cell.mainimage.layer.masksToBounds = false
            cell.mainimage.layer.borderColor = UIColor(red: CGFloat(245.0/255.0), green: CGFloat(245.0/255.0), blue: CGFloat(245.0/255.0), alpha: CGFloat(1.0)).CGColor
            cell.mainimage.layer.cornerRadius = cell.mainimage.frame.height/2
            cell.mainimage.clipsToBounds = true
            
            cell.counter.layer.cornerRadius = cell.counter.frame.height/2
            cell.counter.clipsToBounds = true
            return cell
        }
        if (selectedSegmentIndex == 1) {
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
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (selectedSegmentIndex == 1) {
            if allFiles.count > 0 {
                return 1
            }
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (selectedSegmentIndex == 1) {
            if (section == 0) {
                return "TODAY"
            }
            return "YESTERDAY"
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (selectedSegmentIndex == 1) {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if (selectedSegmentIndex == 1) {
            if (section == 0) {
                label.text = "  TODAY"
            }
            label.text = "  YESTERDAY"
            label.font = UIFont(name: "HelveticaNeue", size: 13.0)!
            label.textColor = UIColor(red: CGFloat(160.0/255.0), green: CGFloat(160.0/255.0), blue: CGFloat(160.0/255.0), alpha: CGFloat(1))
            label.backgroundColor = UIColor(red: CGFloat(242.0/255.0), green: CGFloat(242.0/255.0), blue: CGFloat(242.0/255.0), alpha: CGFloat(1))
        }
        return label
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (selectedSegmentIndex == 0) {
            return 72
        } else {
            return 52
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        if (selectedSegmentIndex == 2) {
            membersCollection.alpha = 1.0
        } else {
            membersCollection.alpha = 0.0
            tableview.reloadData()
        }
    }
    
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allObjects.count + 1
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: MemberCell! = membersCollection.dequeueReusableCellWithReuseIdentifier("MemberCellID", forIndexPath: indexPath) as! MemberCell
        if (indexPath.row > 0) {
            let user = self.allObjects[indexPath.row - 1]
            let imageFile = user.valueForKey("avatar") as? PFFile
            if imageFile != nil {
                imageFile?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                    let imageData = UIImage(data: data!)
                    cell.avatar.image = imageData
                    cell.avatar.contentMode = UIViewContentMode.ScaleAspectFill
                })
            }
            
            cell.username.text = (user.valueForKey("firstName") as? String)! + " " + (user.valueForKey("lastName")  as? String)!
        } else {
            cell.avatar.contentMode = UIViewContentMode.Center
        }
        cell.avatar.layer.borderWidth = 0
        cell.avatar.layer.masksToBounds = false
        cell.avatar.layer.borderColor = UIColor(red: CGFloat(245.0/255.0), green: CGFloat(245.0/255.0), blue: CGFloat(245.0/255.0), alpha: CGFloat(1.0)).CGColor
        cell.avatar.layer.cornerRadius = cell.avatar.frame.height/2
        cell.avatar.clipsToBounds = true
        return cell
    }
    @IBAction func addItems(sender: AnyObject) {
        if (selectedSegmentIndex == 0) {
            self.performSegueWithIdentifier("createFeed", sender: self)
        } else if (selectedSegmentIndex == 1){
            let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
            let addFile = UIAlertAction(title: "Add file", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.documentPicker()
            })
            //
            let takePhoto = UIAlertAction(title: "Take photo", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                
                self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                    
                }
            })
            let fromLibrary = UIAlertAction(title: "From library", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                    
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            //
            //
            //                // 4
            //                optionMenu.addAction(addFeed)
            optionMenu.addAction(addFile)
            optionMenu.addAction(takePhoto)
            optionMenu.addAction(fromLibrary)
            optionMenu.addAction(cancelAction)
            //
            //                // 5
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        //        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        //
        //        // 2
        //
        //        let addFeed = UIAlertAction(title: "Add feed", style: .Default, handler: {
        //            (alert: UIAlertAction!) -> Void in
        //            self.performSegueWithIdentifier("createFeed", sender: self)
        //        })
        //        let addFile = UIAlertAction(title: "Add file", style: .Default, handler: {
        //            (alert: UIAlertAction!) -> Void in
        //            self.documentPicker()
        //        })
        //        //
        //        let takePhoto = UIAlertAction(title: "Take photo", style: .Default, handler: {
        //            (alert: UIAlertAction!) -> Void in
        //            self.imagePicker.allowsEditing = false
        //            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        //
        //            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
        //
        //            }
        //        })
        //        let fromLibrary = UIAlertAction(title: "From library", style: .Default, handler: {
        //            (alert: UIAlertAction!) -> Void in
        //            self.imagePicker.allowsEditing = false
        //            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //
        //            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
        //
        //            }
        //        })
        //        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
        //            (alert: UIAlertAction!) -> Void in
        //
        //        })
        //
        //
        //        // 4
        //        optionMenu.addAction(addFeed)
        //        optionMenu.addAction(addFile)
        //        optionMenu.addAction(takePhoto)
        //        optionMenu.addAction(fromLibrary)
        //        optionMenu.addAction(cancelAction)
        //
        //        // 5
        //        self.presentViewController(optionMenu, animated: true, completion: nil)
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
        
        if segue.identifier == "createFeed" {
            (((segue.destinationViewController as! UINavigationController).viewControllers.first) as! CreateFeedViewController!).feedDelegate = self
        }
    }
    
    @IBAction func openProfile(sender: AnyObject) {
        self.navigationController!.performSegueWithIdentifier("confirmProfileSegue", sender: nil)
    }
    
    func setupFeed(objects : [PFObject]?) {
        self.feeds.removeAllObjects()
        self.feeds.addObjectsFromArray(objects!)
        self.tableview.reloadData()
        
    }
    
    @IBAction func showMenu(sender: AnyObject) {
        
    }
    @IBAction func backGroups(sender: AnyObject) {
      self.navigationController?.popViewControllerAnimated(true)
    }
}
