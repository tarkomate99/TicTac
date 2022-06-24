//
//  ViewController.swift
//  TicTac
//
//  Created by mac on 2022. 06. 23..
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import SwiftUI
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var uploader: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var heartIcon: UIImageView!
    
    @IBOutlet weak var rndImg: UIButton!
    
    private let storage = Storage.storage().reference()
    var paths = [String]()
    var imageViews = [UIImage]()
    var photos = [Photo]()
    var current_id = ""
    var current_index = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        rndImg.setTitleColor(.white, for: .normal)
        loadDatas()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        heartIcon.addGestureRecognizer(tapGR)
        heartIcon.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer){
        if sender.state == .ended {
            let db = Firestore.firestore()
            var likes = Int(likes.text!)
            likes!+=1
            self.likes.text = String(likes!)
            db.collection("images").document(current_id).updateData(["likes": likes])
            self.photos[current_index].likes = likes
        }
    }
    
    @IBAction func uploadPhotoTapped(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url = URL(string: urlString) else {
                return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
            }
        })
        
        task.resume()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storage.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil){
            metadata, error in
            
            if error == nil && metadata != nil {
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url":path,"uploader":"tarkomate99", "upload_date":Date.now,"likes":0]) { error in
                    
                    if error == nil{
                        self.retrievePhotos()
                    }
                    
                }
            }
        }
        
        
    }
    
    func retrievePhotos() {
        let db = Firestore.firestore()
        db.collection("images").getDocuments {
            snapshot, error in
            if error == nil && snapshot != nil{
                for doc in snapshot!.documents {
                    self.paths.append(doc["url"] as! String)
                }
                
                
                
                for path in self.paths {
                    let storageRef = Storage.storage().reference()
                    let fileRef = storageRef.child(path)
                    
                    fileRef.getData(maxSize: 5*1024*1024){ data, error in
                        if let image = UIImage(data: data!){
                            self.imageViews.append(image)
                        }
                    }
                }
            }
        }
    }
    
    
    func loadDatas(){
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        let storage = Storage.storage().reference()
        db.collection("images").getDocuments{ (snapshot, error) in
            if error == nil && snapshot != nil{
                for doc in snapshot!.documents{
                    let data = doc.data()
                    let id = doc.documentID
                    let likes = data["likes"] as? Int
                    let up_date = (data["upload_date"] as? Timestamp)?.dateValue() ?? Date()
                    let uploader = data["uploader"] as? String
                    let url = data["url"] as! String
                    let fileRef = storage.child(url)
                    fileRef.getData(maxSize: 5*1024*1024){ data, error in
                        if let image = UIImage(data: data!){
                            let photo = Photo(id: id, likes: likes, date: up_date, uploader: uploader, url: url, image: image)
                            self.photos.append(photo)
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func pickRandomImage(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let arraylen = self.photos.count
        let randomInt = Int.random(in: 0...arraylen-1)
        self.current_index = randomInt
        //let img = self.imageViews[randomInt]
        let photo = self.photos[randomInt]
        DispatchQueue.main.async {
            self.imgView.image = photo.image
            self.likes.text = String(photo.likes!)
            self.uploader.text = photo.uploader
            self.date.text = dateFormatter.string(from: photo.date!)
            self.likes.adjustsFontSizeToFitWidth = true
            self.likes.font = self.likes.font.withSize(17)
            self.uploader.adjustsFontSizeToFitWidth = true
            self.uploader.font = self.uploader.font.withSize(17)
            self.date.adjustsFontSizeToFitWidth = true
            self.date.font = self.date.font.withSize(17)
        }
        
        
        self.current_id = photo.id!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
}

