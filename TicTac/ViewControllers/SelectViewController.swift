//
//  SelectViewController.swift
//  TicTac
//
//  Created by mac on 2022. 06. 25..
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation
class SelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func openCameraButton(sender: AnyObject){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
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
    
    @IBAction func selectVideo(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true)
        
        if let mediaInfo = info[UIImagePickerController.InfoKey.mediaType] as? String{
            if mediaInfo == "public.movie"{
                guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {
                    return
                }
                do {
                    let data = try Data(contentsOf: videoUrl as URL)
                    let name = "videos/\(UUID().uuidString).mp4"
                    let storageRef = Storage.storage().reference().child(name)
                    if let uploadData = data as Data?{
                        let metaData = StorageMetadata()
                        metaData.contentType = "video/mp4"
                        storageRef.putData(uploadData, metadata: metaData, completion: { (metadata, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }else{
                                storageRef.downloadURL { (url, error) in
                                    guard let downloadURL = url else {
                                        print(error?.localizedDescription)
                                        return
                                    }
                                    print(downloadURL)
                                    let db = Firestore.firestore()
                                    let user = Auth.auth().currentUser
                                    db.collection("videos").document().setData(["url":url?.absoluteString,"uploader":user?.email, "upload_date":Date.now,"likes":0])
                                }
                            }
                        })
                    }
                }catch let error {
                    print(error.localizedDescription)
                }
            }
            
            if mediaInfo == "public.image"{
                guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                    return
                }
                let imageData = image.jpegData(compressionQuality: 0.8)
                
                guard imageData != nil else {
                    return
                }
                let path = "images/\(UUID().uuidString).jpg"
                let fileRef = Storage.storage().reference().child(path)
                let user = Auth.auth().currentUser
                let uploadTask = fileRef.putData(imageData!, metadata: nil){
                    metadata, error in
                    
                    if error == nil && metadata != nil {
                        let db = Firestore.firestore()
                        db.collection("images").document().setData(["url":path,"uploader":user?.email, "upload_date":Date.now,"likes":0]) { error in
                            
                        }
                    }
                }
            }
        }
        
        
    }

}
