//
//  TableViewCell.swift
//  trial 3
//
//  Created by Ansar Khan on 2018-05-31.
//  Copyright © 2018 Guest User. All rights reserved.
//
import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    var view: UIView?;
    

    @IBOutlet weak var thumbnail: UIImageView!
 
    @IBOutlet weak var timeField: UILabel!
    
    @IBOutlet weak var scoreField: UILabel!
    //    required init?(coder aDecoder: NSCoder) {
    //       // fatalError("init(coder:) has not been implemented")
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        self.frame.size.height = scoreField.frame.height+timeField.frame.width
        timeField.font = UIFont(name: "Avenir-Heavy", size: 20)
        scoreField.font = UIFont(name: "Avenir-Heavy", size: 20)
        timeField.textColor = UIColor(red: 200.0/255.0, green: 92.0/255.0, blue: 118.0/255.0, alpha: 1)
        scoreField.textColor = UIColor(red: 63.0/255.0, green: 104.0/255.0, blue: 112.0/255.0, alpha: 255.0/255.0)
        thumbnail.image = UIImage(named: "stars.png")
        timeField.frame.size.width = self.frame.width-thumbnail.frame.width-10
        scoreField.frame.size.width = timeField.frame.width
        thumbnail.frame.size.height = self.frame.height
        thumbnail.frame.size.width = thumbnail.frame.height
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        view = UIView(frame: self.frame);
        view?.backgroundColor = .red
        // Configure the view for the selected state
    }
    
}
