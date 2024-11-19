//
//  SkiResortTableViewCell.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import UIKit

class SkiResortTableViewCell: UITableViewCell {

    static let identifier = "SkiResortTableViewCell"
    @IBOutlet weak var nameLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "SkiResortTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.font = UIFont(name: "851tegakizatsu", size: 24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
