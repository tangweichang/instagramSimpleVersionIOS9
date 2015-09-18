//
//  FeedTableViewController.swift
//  ParseStarterProject
//
//  Created by TangWeichang on 8/24/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    var messages = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    var users = [String:String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            
                // The find succeeded.
                // Do something with the found objects
            if let users = objects as? [PFObject] {
                self.messages.removeAll(keepCapacity: true)
                self.usernames.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                self.users.removeAll(keepCapacity: true)
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username!
                            
                    }
                }
            }
            let getFollowedUsersQuery = PFQuery(className:"followers")
            getFollowedUsersQuery.whereKey("follower", equalTo:PFUser.currentUser()!.objectId!)
            getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if let objects = objects {
                    for object in objects {
                        let followedUser = object["following"] as! String
                        let query = PFQuery(className:"Post")
                        query.whereKey("userId", equalTo: followedUser)
                        query.findObjectsInBackgroundWithBlock{(objects, error) -> Void in
                            if let objects = objects {
                                for object in objects {
                                    self.messages.append(object["message"] as! String)
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    self.usernames.append(self.users[object["userId"] as! String]!)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cell
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            if let downloadedImage = UIImage(data:data!) {
                myCell.postedImage.image = downloadedImage
            }
        }
        myCell.postedImage.image = UIImage(named: "user.png")
        myCell.username.text = usernames[indexPath.row]
        myCell.message.text = messages[indexPath.row]
        return myCell
    }
    
}
