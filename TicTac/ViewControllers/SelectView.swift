//
//  SelectView.swift
//  TicTac
//
//  Created by mac on 2022. 06. 26..
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation
struct SelectView: View {
    @State private var isShowGallery = false
    @State private var isShowCamera = false
    @State private var isShowVideoGallery = false

    
    var body: some View {
        VStack(spacing: 20){
            Button(action: {
                self.isShowCamera = true
            }, label:{
                Text("Camera")
                    .frame(minWidth: 0, maxWidth: 300)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }).sheet(isPresented: $isShowCamera){
                CameraView(sourceType: .camera)
            }
            Button(action: {
                self.isShowGallery = true
            }, label:{
                Text("Galéria")
                    .frame(minWidth: 0, maxWidth: 300)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }).sheet(isPresented: $isShowGallery){
                ImagePicker(sourceType: .photoLibrary)
            }
            Button(action: {
                self.isShowVideoGallery = true
            }, label:{
                Text("Video")
                    .frame(minWidth: 0, maxWidth: 300)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }).sheet(isPresented: $isShowVideoGallery){
                VideoLibrary(sourceType: .photoLibrary)
            }
        }
    }
    
    
}

struct ImagePicker: UIViewControllerRepresentable{
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        var parent: ImagePicker
        
        init(_ parent: ImagePicker){
            self.parent = parent
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

struct CameraView: UIViewControllerRepresentable{
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> some UIViewController {
        let cameraViewController = UIImagePickerController()
        cameraViewController.sourceType = sourceType
        cameraViewController.allowsEditing = false
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        var parent: CameraView
        
        init(_ parent: CameraView){
            self.parent = parent
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

struct VideoLibrary: UIViewControllerRepresentable{
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoLibrary>) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        return picker
    }
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        var parent: VideoLibrary
        
        init(_ parent: VideoLibrary){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            picker.dismiss(animated: true)
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
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
