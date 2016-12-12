//
//  FlightTableViewCell.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/28/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
