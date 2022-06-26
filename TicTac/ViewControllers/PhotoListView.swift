//
//  PhotoListView.swift
//  TicTac
//
//  Created by mac on 2022. 06. 26..
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import AVKit
import AVFoundation
struct PhotoListView: View {
    
    @State var photos = [Photo]()
    @State var videos = [Video]()
    @State private var fgColor: Color = .gray
    @State private var image: String = "heart"
    
    @State var currentScale: CGFloat = 0
    @State var finalScale: CGFloat = 1
    
    let dateFormatter = DateFormatter()
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                ForEach(0..<self.photos.count, id: \.self){ i in
                    HStack{
                        Image(systemName: "person.circle.fill")
                        Text(self.photos[i].uploader!)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    var likes = self.photos[i].likes!
                    Image(uiImage: self.photos[i].image!).resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                        .scaleEffect(finalScale + currentScale)
                        .gesture(MagnificationGesture()
                            .onChanged{ newScale in
                                currentScale = newScale
                            }
                            .onEnded{ scale in
                                finalScale = scale
                                currentScale = 0
                            }
                        )
                        .onTapGesture(count: 2){
                            if Auth.auth().currentUser == nil{
                                return
                            }else{
                                if image == "heart" && fgColor == .gray{
                                    image = "heart.fill"
                                    fgColor = .red
                                    let db = Firestore.firestore()
                                    likes+=1
                                    db.collection("images").document(self.photos[i].id!).updateData(
                                        ["likes": likes])
                                    self.photos[i].likes = likes
                                }else if image == "heart.fill" && fgColor == .red{
                                    image = "heart"
                                    fgColor = .gray
                                    let db = Firestore.firestore()
                                    likes-=1
                                    db.collection("images").document(self.photos[i].id!).updateData(
                                        ["likes": likes])
                                    self.photos[i].likes = likes
                                }
                            }
                        }
                    HStack{
                        var likes = self.photos[i].likes!
                        Image(systemName: image)
                            .foregroundColor(fgColor)
                            .onTapGesture{
                                if Auth.auth().currentUser == nil{
                                    return
                                }else{
                                    if image == "heart" && fgColor == .gray{
                                        image = "heart.fill"
                                        fgColor = .red
                                        let db = Firestore.firestore()
                                        likes+=1
                                        db.collection("images").document(self.photos[i].id!).updateData(
                                            ["likes": likes])
                                        self.photos[i].likes = likes
                                    }else if image == "heart.fill" && fgColor == .red{
                                        image = "heart"
                                        fgColor = .gray
                                        let db = Firestore.firestore()
                                        likes-=1
                                        db.collection("images").document(self.photos[i].id!).updateData(
                                            ["likes": likes])
                                        self.photos[i].likes = likes
                                    }
                                }
                            }
                        Text(String(likes))
                        Spacer(minLength: 80)
                        Text(self.photos[i].date!, style: .date)
                    }
                    Divider().padding()
                }
                ForEach(0..<self.videos.count, id: \.self){ i in
                    HStack{
                        Image(systemName: "person.circle.fill")
                        Text(self.videos[i].uploader!)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    let url = URL(string: self.videos[i].url!)
                    VideoPlayer(player: AVPlayer(url: url!)).frame(width: 300, height: 300, alignment: .center)
                    HStack{
                        var likes = self.videos[i].likes!
                        Image(systemName: image)
                            .foregroundColor(fgColor)
                            .onTapGesture{
                                if Auth.auth().currentUser == nil{
                                    return
                                }else{
                                    if image == "heart" && fgColor == .gray{
                                        image = "heart.fill"
                                        fgColor = .red
                                        let db = Firestore.firestore()
                                        likes+=1
                                        db.collection("videos").document(self.videos[i].id!).updateData(
                                            ["likes": likes])
                                        self.videos[i].likes = likes
                                    }else if image == "heart.fill" && fgColor == .red{
                                        image = "heart"
                                        fgColor = .gray
                                        let db = Firestore.firestore()
                                        likes-=1
                                        db.collection("videos").document(self.videos[i].id!).updateData(
                                            ["likes": likes])
                                        self.videos[i].likes = likes
                                    }
                                    /*
                                     self.photos.removeAll()
                                     loadDatas()
                                     */
                                }
                            }
                        Text(String(likes))
                        Spacer(minLength: 80)
                        Text(self.videos[i].date!, style: .date)
                    }
                    Divider()
                }
            }.onAppear{
                self.photos.removeAll()
                self.videos.removeAll()
                loadDatas()
                loadVideos()
            }
        }.frame(width: .infinity, height: .infinity)
    }
    
    func loadVideos(){
        let db = Firestore.firestore()
        db.collection("videos").order(by: "upload_date", descending: true).getDocuments{ (snapshot, error) in
            if error == nil && snapshot != nil{
                for doc in snapshot!.documents{
                    let data = doc.data()
                    let id = doc.documentID
                    let likes = data["likes"] as? Int
                    let up_date = (data["upload_date"] as? Timestamp)?.dateValue() ?? Date()
                    let uploader = data["uploader"] as? String
                    let url = data["url"] as! String
                    let video = Video(id: id, likes: likes, date: up_date, uploader: uploader, url: url)
                    videos.append(video)
                }
            }
            
        }
    }
    
    
    func loadDatas(){
        let db = Firestore.firestore()
        let storage = Storage.storage().reference()
        db.collection("images").order(by: "upload_date", descending: true).getDocuments{ (snapshot, error) in
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
                            photos.append(photo)
                        }
                    }
                }
            }
            
        }
    }
}

struct PhotoListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListView()
    }
}
