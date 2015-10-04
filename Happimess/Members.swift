//
//  Members.swift
//  Happimess
//
//  Created by Nikita Feshchun on 02.10.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit

class Members : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var membersCollection: UICollectionView!
    
    var menuItem : BTNavigationDropdownMenu!
    let items = ["Active group", "Files", "Members"]
    let sectionInsets = UIEdgeInsets(top: 18.0, left: 12.0, bottom: 12.0, right: 12.0)
    var allObjects : NSMutableArray = []
    var allFiles : NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersCollection.registerNib(UINib(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: "MemberCellID")
        //        tableview.registerClass(FeedCell.classForCoder(), forCellReuseIdentifier: "FeedCellID")
      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let queryMembers = PFQuery(className: "_User")
        queryMembers.whereKey("email", notEqualTo: (PFUser.currentUser()?.valueForKey("email"))!)
        queryMembers.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            self.allObjects.removeAllObjects()
            self.allObjects.addObjectsFromArray(objects!)
            self.membersCollection.reloadData()
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
            let imageData = UIImage(named: "add")
            cell.avatar.image = imageData
            cell.avatar.contentMode = UIViewContentMode.Center
        }
        cell.avatar.layer.borderWidth = 0
        cell.avatar.layer.masksToBounds = false
        cell.avatar.layer.borderColor = UIColor(red: CGFloat(245.0/255.0), green: CGFloat(245.0/255.0), blue: CGFloat(245.0/255.0), alpha: CGFloat(1.0)).CGColor
        cell.avatar.layer.cornerRadius = cell.avatar.frame.height/2
        cell.avatar.clipsToBounds = true
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func openProfile(sender: AnyObject) {
        self.navigationController!.performSegueWithIdentifier("confirmProfileSegue", sender: nil)
    }
    
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

