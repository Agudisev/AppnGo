//
//  NFCModel.swift
//  app
//
//  Created by dhruv patel on 6/7/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import Foundation
import UIKit

class NFCModel {
    var Price: String
    var Name: String
    var ProfileImageURL: String
    
    init(Price: String, Name: String, profileImageURL: String){
        self.Price = Price
        self.Name = Name
        self.ProfileImageURL = profileImageURL
    }
}
