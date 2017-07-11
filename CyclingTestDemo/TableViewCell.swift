//
//  TableViewCell.swift
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/9.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(object: CyclingData) {
        self.textLabel?.text =  dateFormatter.string(from: object.startDate) + "一共:\(object.cyclingLocations.count)点"
    }
}
