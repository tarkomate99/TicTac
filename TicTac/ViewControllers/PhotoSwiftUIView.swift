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
struct PhotoSwiftUIView: View {
    
    @State var photos = [Photo]()
    let dateFormatter = DateFormatter()
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                ForEach(0..<self.photos.count, id: \.self){ i in
                    Image(uiImage: self.photos[i].image!).resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                    HStack{
                        Image(systemName: "heart.fill").onTapGesture {
                            if Auth.auth().currentUser == nil{
                                return
                            }else{
                                let db = Firestore.firestore()
                                var likes = self.photos[i].likes!
                                likes+=1
                                db.collection("images").document(self.photos[i].id!).updateData(
                                    ["likes": likes])
                                self.photos[i].likes = likes
                                self.photos.removeAll()
                                loadDatas()
                                }
                            }
                        Text(String(self.photos[i].likes!))
                        Divider()
                        Text(self.photos[i].uploader!)
                        Divider()
                        Text(self.photos[i].date!, style: .date)
                    }
                    Divider().padding()
                    }
                    
                }.onAppear{
                    loadDatas()
                }
                
            }.frame(width: .infinity, height: .infinity)
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
