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
import FirebaseAuth
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var uploader: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var heartIcon: UIImageView!
    @IBOutlet weak var rndImg: UIButton!
    @IBOutlet weak var loginOrLogoutBtn: UIBarButtonItem!
    @IBOutlet weak var uploadBarBtn: UIBarButtonItem!
    
    var isUserAuth = false
    
    private let storage = Storage.storage().reference()
    var paths = [String]()
    var imageViews = [UIImage]()
    var photos = [Photo]()
    var current_id = ""
    var current_index = 0
    
    let photoView = UIHostingController(rootView: PhotoSwiftUIView())
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if Auth.auth().currentUser != nil {
            self.loginOrLogoutBtn.title = "Kijelentkezés"
            self.loginOrLogoutBtn.target = self
            self.loginOrLogoutBtn.action = #selector(logOut)
            self.uploadBarBtn.target = self
            self.uploadBarBtn.action = #selector(showSelectPage)
        }else{
            self.loginOrLogoutBtn.title = "Bejelentkezés"
            self.loginOrLogoutBtn.target = self
            self.loginOrLogoutBtn.action = #selector(showLoginPage)
            self.uploadBarBtn.target = self
            self.uploadBarBtn.action = #selector(showLoginPage)
        }
        addChild(photoView)
        view.addSubview(photoView.view)
        setupConstraints()
        
        loadDatas()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        heartIcon.addGestureRecognizer(tapGR)
        heartIcon.isUserInteractionEnabled = true
        self.uploader.alpha = 0
        self.date.alpha = 0
        self.heartIcon.alpha = 0
        self.likes.alpha = 0
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: true)
    
        
    }
    
    fileprivate func setupConstraints(){
        photoView.view.translatesAutoresizingMaskIntoConstraints = false
        photoView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        photoView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        photoView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        photoView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc func showSelectPage(){
        let selectViewController = self.storyboard?.instantiateViewController(identifier: "UploadVC") as? SelectViewController
        self.navigationController?.pushViewController(selectViewController!, animated: true)
    }
    
    @objc func showLoginPage(){
        let loginViewController = self.storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginViewController
        self.navigationController?.pushViewController(loginViewController!, animated: true)
    }
    
    @objc func logOut(){
        try! Auth.auth().signOut()
        DispatchQueue.main.async {
            self.loginOrLogoutBtn.title = "Bejelentkezés"
            self.loginOrLogoutBtn.target = self
            self.loginOrLogoutBtn.action = #selector(self.showLoginPage)
            self.uploadBarBtn.target = self
            self.uploadBarBtn.action = #selector(self.showLoginPage)
        }
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer){
        if Auth.auth().currentUser == nil{
            return
        }else{
            if sender.state == .ended {
                let db = Firestore.firestore()
                var likes = Int(likes.text!)
                likes!+=1
                self.likes.text = String(likes!)
                db.collection("images").document(current_id).updateData(["likes": likes])
                self.photos[current_index].likes = likes
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
        self.uploader.alpha = 1
        self.date.alpha = 1
        self.heartIcon.alpha = 1
        self.likes.alpha = 1
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

