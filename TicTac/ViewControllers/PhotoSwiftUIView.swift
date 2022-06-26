//
//  PhotoSwiftUIView.swift
//  TicTac
//
//  Created by mac on 2022. 06. 25..
//

import SwiftUI
import FirebaseAuth
struct PhotoSwiftUIView: View {
    
    var body: some View {
        
        TabView{
            PhotoListView()
                .tabItem{
                    Image(systemName: "house")
                    Text("Home")
                }
            SelectView()
                .tabItem{
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                    Text("Feltöltés")
                }
        }
        
    }
}

struct PhotoSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSwiftUIView()
    }
}
