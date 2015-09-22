//
//  SearchUniversity.swift
//  Happimess
//
//  Created by Nikita Feshchun on 22.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//

import UIKit

class SearchUniversity : UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    let universities : [Univercity] = [Univercity(name: "Univercity 1"),Univercity(name: "Univercity 2"),Univercity(name: "Univercity 3"),Univercity(name: "Univercity 4")]
    var filteredUnivercities : [Univercity] = []
    var searchActive : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.reloadData()
        
    }
 
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredUnivercities.count
        }
        return self.universities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Get the corresponding candy from our candies array
        var university = Univercity(name: "")
        if(searchActive){
            university = self.filteredUnivercities[indexPath.row]
        } else {
            university = self.universities[indexPath.row]
        }
        
        
        // Configure the cell
        cell.textLabel!.text = university.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredUnivercities = universities.filter({ (Univercity) -> Bool in
            let tmp: NSString = Univercity.name
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(searchText == ""){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
}