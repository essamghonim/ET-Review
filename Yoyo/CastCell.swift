//
//  CastCell.swift
//  Yoyo
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//

import UIKit
class CastCell: UITableViewCell
{
    @IBOutlet weak var CastJob: UILabel!
    @IBOutlet weak var CastImage: UIImageView!
    @IBOutlet weak var CastName: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        CastImage?.layer.cornerRadius = 35
        CastImage?.clipsToBounds = true
        // Configure the view for the selected state
    }
}
