//
//  Photo.swift
//  TicTac
//
//  Created by mac on 2022. 06. 23..
//

import Foundation

class Photo{
    
    var id: String?
    var likes: Int?
    var date: Date?
    var uploader: String?
    var url: String?
    
    init(id: String?, likes: Int?, date: Date?, uploader: String?, url: String?){
        self.id = id
        self.likes = likes
        self.date = date
        self.uploader = uploader
        self.url = url
    }
    
}
