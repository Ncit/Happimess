//
//  GroupsViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 04.10.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit

class GroupsViewController : UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var allObjects : NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCellID")
        let queryMembers = PFQuery(className: "_User")
        queryMembers.whereKey("email", notEqualTo: (PFUser.currentUser()?.valueForKey("email"))!)
        queryMembers.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error : NSError?) -> Void in
            if (objects != nil) {
                self.allObjects.removeAllObjects()
                self.allObjects.addObjectsFromArray(objects!)
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell: GroupCell! = tableView.dequeueReusableCellWithIdentifier("GroupCellID") as? GroupCell
        cell.counter.layer.cornerRadius = cell.counter.frame.height/2
        cell.counter.clipsToBounds = true
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.title.text = "First Group"
        cell.mainimage.image = UIImage(named: "top_bg.png")
        cell.firstUser.layer.cornerRadius = cell.firstUser.frame.height/2
        cell.firstUser.clipsToBounds = true
        cell.secondUser.layer.cornerRadius = cell.secondUser.frame.height/2
        cell.secondUser.clipsToBounds = true
        cell.counter.text = "999"
        if allObjects.count > 0 {
            let user = self.allObjects[0]
            let imageFile = user.valueForKey("avatar") as? PFFile
            if imageFile != nil {
                imageFile?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                    let imageData = UIImage(data: data!)
                    cell.firstUser.image = imageData
                    cell.firstUser.contentMode = UIViewContentMode.ScaleAspectFill
                })
            }
            let user2 = self.allObjects[1]
            let imageFile2 = user2.valueForKey("avatar") as? PFFile
            if imageFile2 != nil {
                imageFile2?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                    let imageData = UIImage(data: data!)
                    cell.secondUser.image = imageData
                    cell.secondUser.contentMode = UIViewContentMode.ScaleAspectFill
                })
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("feedsSegue", sender: nil)
    }
    
}
