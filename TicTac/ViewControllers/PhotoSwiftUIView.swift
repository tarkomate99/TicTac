//
//  PhotoSwiftUIView.swift
//  TicTac
//
//  Created by mac on 2022. 06. 25..
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import AVKit
import AVFoundation
struct PhotoSwiftUIView: View {
    
    @State var photos = [Photo]()
    @State var videos = [Video]()
    @State private var fgColor: Color = .gray
    @State private var image: String = "heart"
    let dateFormatter = DateFormatter()
    
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                ForEach(0..<self.photos.count, id: \.self){ i in
                    var isTapped: Bool = false
                    HStack{
                        Image(systemName: "person.circle.fill")
                        Text(self.photos[i].uploader!)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Image(uiImage: self.photos[i].image!).resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                    HStack{
                        var likes = self.photos[i].likes!
                        Image(systemName: image)
                            .foregroundColor(fgColor)
                            .onTapGesture{
                            if Auth.auth().currentUser == nil{
                                return
                            }else{
                                image = "heart.fill"
                                fgColor = .red
                                let db = Firestore.firestore()
                                likes+=1
                                db.collection("images").document(self.photos[i].id!).updateData(
                                    ["likes": likes])
                                self.photos[i].likes = likes
                                /*
                                self.photos.removeAll()
                                loadDatas()
                                 */
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
                                image = "heart.fill"
                                fgColor = .red
                                let db = Firestore.firestore()
                                likes+=1
                                db.collection("images").document(self.photos[i].id!).updateData(
                                    ["likes": likes])
                                self.photos[i].likes = likes
                                /*
                                self.videos.removeAll()
                                loadVideos()
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
        db.collection("videos").getDocuments{ (snapshot, error) in
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
                            photos.append(photo)
                        }
                    }
                }
            }
            
        }
    }
}

struct PhotoSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSwiftUIView()
    }
}
