//
//  HelpViewController.swift
//  DroneAssist
//
//  Created by Benjamin Durao on 11/15/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import Foundation
import UIKit

class HelpViewController: UITableViewController {
    override func viewDidLoad() {
        tableView.contentInset.top = 20
        tableView.delegate = self
    }
    
   /* override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "AppIcon.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        // center and scale background image
        imageView.contentMode = .scaleAspectFit
        
        // Set the background color to match better
        tableView.backgroundColor = UIColor.lightGray
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    } */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
}
