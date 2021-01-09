//
//  TableViewCell.swift
//  app
//
//  Created by dhruv patel on 6/7/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import Kingfisher

class TableViewCell: UITableViewCell {

  
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblImage: UIImageView!
    
    @IBOutlet weak var viewCell: UIView!
    
    @IBOutlet weak var cellView: UIView!
    
    
    
    var nfcModel: NFCModel? {
        didSet{
            lblPrice.text = nfcModel?.Name
            let url = URL(string: (nfcModel?.ProfileImageURL)!)
            if let url = url as? URL {
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil,  completionHandler: { (image, error, cache, imageURL) in
                    self.lblImage.image = image
                    self.lblImage.kf.indicatorType = .activity
                           })
            }
            
        }
        }
    
    func roundedImage() {
        lblImage.layer.borderWidth = 1
        lblImage.layer.masksToBounds = false
        lblImage.layer.borderColor = UIColor.black.cgColor
        lblImage.layer.cornerRadius = lblImage.frame.height/2
        lblImage.clipsToBounds = true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
