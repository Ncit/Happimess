//
//  Threads.swift
//  Happimess
//
//  Created by Nikita Feshchun on 22.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class Threads : UIViewController,UITableViewDataSource,UITableViewDelegate {
    let items = ["Feeds", "Files", "Members"]
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuView = BTNavigationDropdownMenu(title: items.first!, items: items)
        menuView.maskBackgroundColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "HelveticaNeue-Thin", size: 17.0)!
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            
        }
        self.navigationItem.titleView = menuView
        tableview.registerNib(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCellID")
//        tableview.registerClass(FeedCell.classForCoder(), forCellReuseIdentifier: "FeedCellID")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell: FeedCell! = tableView.dequeueReusableCellWithIdentifier("FeedCellID") as? FeedCell
        
        cell.info?.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        cell.title?.text = "Click me! i am active"
        cell.avatar.image = UIImage(named:("avatar.png"))!
        cell.mainimage.image = UIImage(named:("avatar.png"))!
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
        cell.counter.text = "\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
