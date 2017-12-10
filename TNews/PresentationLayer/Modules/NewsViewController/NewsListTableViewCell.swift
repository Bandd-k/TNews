//
//  NewsListTableViewCell.swift
//  TNews
//
//  Created by Denis Karpenko on 05.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    var news :News?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(from element: News){
        counterLabel.text = "\(element.count?.counter ?? 0)"
        nameLabel.text = element.text
        news = element
    }
}
