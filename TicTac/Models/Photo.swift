//
//  Photo.swift
//  TicTac
//
//  Created by mac on 2022. 06. 23..
//

import Foundation
import UIKit

class Photo{
    
    var id: String?
    var likes: Int?
    var date: Date?
    var uploader: String?
    var url: String?
    var image: UIImage?
    
    init(id: String?, likes: Int?, date: Date?, uploader: String?, url: String?, image: UIImage?){
        self.id = id
        self.likes = likes
        self.date = date
        self.uploader = uploader
        self.url = url
        self.image = image
    }
    
}
