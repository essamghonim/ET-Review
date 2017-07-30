//
//  MovieCell.swift
//  Yoyo
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//

import UIKit
class MovieCell: UITableViewCell
{
    @IBOutlet weak var MoviePicture: UIImageView!
    @IBOutlet weak var MovieLabel: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
