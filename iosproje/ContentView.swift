
//  ContentView.swift
//  iosproje
//
//  Created by Canberk BİBİCAN on 24.04.2020.
//  Copyright © 2020 Canberk BİBİCAN. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

// ---------------------------------------------- CONTENT VIEW
// TOP NAVIGATION BAR

struct ContentView: View {
    var body: some View {
        
        TabView{
            
            NavigationView{
                
                Home()
                    .navigationBarTitle("Instagram")
                    .navigationBarItems(leading: Button(action: {
                        
                    }, label: {
                        
                        Image("cam").resizable().frame(width: 30, height: 30)
                        
                    })
                        .foregroundColor(Color("darkAndWhite"))
                        , trailing:
                        
                        HStack{
                            
                            Button(action: {
                                
                            }) {
                                
                                Image("IGTV").resizable().frame(width: 30, height: 30)
                                
                            }.foregroundColor(Color("darkAndWhite"))
                            
                            Button(action: {
                                
                            }) {
                                
                                Image("send").resizable().frame(width: 30, height: 30)
                            }
                            .foregroundColor(Color("darkAndWhite"))
                        }
                        
                )
// BOTTOM NAVIGATION BAR
            }.tabItem {
                
                Image("home")
            }
            
            Text("Find").tabItem {
                
                Image("find")
            }
            
            Text("Upload").tabItem {
                
                Image("plus")
            }
            
            Text("Likes").tabItem {
                
                Image("heart")
            }
            
            Text("Profile").tabItem {
                
                Image("people")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




// ---------------------------------------------- HOME VIEW

struct Home : View {
    
    @ObservedObject var observed = observer()
    @ObservedObject var postsobserver = Postsobserver()
    @State var show = false
    @State var user = ""
    @State var url = ""
    
    var body : some View{
        
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack{
                
                //Ust tarafta gorulen profil resimleri
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack{
                        
                        ForEach(observed.status){i in
                            
                            StatusCard(imName: i.image, user: i.name, show: self.$show, user1: self.$user, url: self.$url).padding(.leading, 10)
                        }
                        
                    }
                }
                if postsobserver.posts.isEmpty{
                    
                    Text("No Posts").fontWeight(.heavy)
                }
                else{
                ForEach(postsobserver.posts){i in
                    
                    postCard(user: i.name, image: i.image, image1: i.image1, id: i.id, likes: i.likes, comments: i.comments)
                    }
                }
            }
        }.sheet(isPresented: $show) {
            
            statusView(url: self.url,name: self.user)
        }
    }
}





// ---------------------------------------------- STATUSCARD VIEW
//Story resim cerceveleri

struct StatusCard : View{
    var imName = ""
    var user = ""
    @Binding var show : Bool
    @Binding var user1 : String
    @Binding var url : String
    
    var body : some View{
        
        VStack{
            
            AnimatedImage(url: URL(string: imName))
                .resizable()
                .frame(width: 80 , height: 80)
                .clipShape(Circle())
                .onTapGesture {
                    
                    self.user1=self.user
                    self.url = self.imName
                    self.show.toggle()
                    
            }
            Text(user).fontWeight(.light)
        }
    }
}


// ---------------------------------------------- POSTCARD VIEW
// POST BOTTOM BUTTONS AND STATS
struct postCard : View {
    
    var user = ""
    var image = ""
    var image1 = ""
    var id = ""
    var likes = ""
    var comments = ""
    
    var body : some View{
        
        VStack(alignment: .leading, content: {
 
            HStack{
                
                AnimatedImage(url: URL(string: image1)).resizable().frame(width: 30, height: 30).clipShape(Circle())
                Text(user)
                Spacer()
                Button(action: {
                    
                }) {
                    
                    Image("menu").resizable().frame(width: 15, height: 15)
                }.foregroundColor(Color("darkAndWhite"))
            }
            
            AnimatedImage(url: URL(string: image)).resizable().frame(height: 350)
            
            HStack{
                
                Button(action: {
                    
// LIKELARIN UPDATE ISLEMI
                    
                }) {
                    
                    Image("comment").resizable().frame(width: 26, height: 26)
                }.foregroundColor(Color("darkAndWhite"))
                
                Button(action: {
                    
                    // update likes...
                    
                    let db = Firestore.firestore()
                   
                    let like = Int.init(self.likes)!
                    db.collection("posts").document(self.id).updateData(["likes": "\(like + 1)"]) { (err) in
                        
                        if err != nil{
                            
                            print((err))
                            return
                        }
                        
                        print("updated....")
                    }
                    
                }) {
                    
                    Image("heart").resizable().frame(width: 26, height: 26)
                }.foregroundColor(Color("darkAndWhite"))
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    
                    Image("saved").resizable().frame(width: 30, height: 30)
                }.foregroundColor(Color("darkAndWhite"))
                
            }.padding(.top, 8)
            
            
            Text("\(likes) Likes").padding(.top, 8)
            Text("View all \(comments) Comments")
            
         }).padding(8)
    }
}

// ---------------------------------------------- OBSERVER
// Firebase cloud storage baglantisi resim kontrolleri

class observer : ObservableObject{
    
    @Published var status = [datatype]()
    
    init() {
        
        let db = Firestore.firestore()
        db.collection("status").addSnapshotListener { (snap, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges{
                
                if i.type == .added{
                    
                    let id = i.document.documentID
                    let name = i.document.get("name") as! String
                    let image = i.document.get("image") as! String
                    
                    self.status.append(datatype(id: id, name: name, image: image))
                }
                
                if i.type == .removed{
                    
                    let id = i.document.documentID
                    
                    
                    for j in 0..<self.status.count{
                        
                        if self.status[j].id == id{
                            
                            self.status.remove(at: j)
                            return
                        }
                    }
                }
            }
        }
    }
}

// ---------------------------------------------- POSTOBSERVER
// SUREKLI OLARAK YENI GONDERI VAR MI DIYE TAKIP EDIYOR
class Postsobserver : ObservableObject{
    
    @Published var posts = [datatype1]()
    
    init() {
        
        let db = Firestore.firestore()
        db.collection("posts").addSnapshotListener { (snap, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges{
                
                if i.type == .added{
                    //firebase icine yazilan alanlar
                    let id = i.document.documentID
                    let name = i.document.get("name") as! String
                    let image = i.document.get("image") as! String
                    let image1 = i.document.get("image1") as! String
                    let comment = i.document.get("comments") as! String
                    let likes = i.document.get("likes") as! String
                    
                    self.posts.append(datatype1(id: id, name: name, image: image, image1: image1, comments: comment, likes: likes))
                }
                
                if i.type == .removed{
                    
                    let id = i.document.documentID
                    
                    
                    for j in 0..<self.posts.count{
                        
                        if self.posts[j].id == id{
                            
                            self.posts.remove(at: j)
                            return
                        }
                    }
                }
// YENI LIKE TAKIBI
                if i.type == .modified{
                                   
                                   let id = i.document.documentID
                                   let likes = i.document.get("likes") as! String
                                   
                                   for j in 0..<self.posts.count {
                                       
                                       if self.posts[j].id == id{
                                           
                                           self.posts[j].likes = likes
                                           return
                                       }
                                   }
                                   
                               }
            }
        }
    }
}
// ----------------------------------------------

struct datatype1 : Identifiable {
    
    var id : String
    var name : String
    var image : String
    var image1 : String
    var comments : String
    var likes : String
}

// ----------------------------------------------

// ----------------------------------------------

struct datatype : Identifiable {
    
    var id : String
    var name : String
    var image : String
}

// ----------------------------------------------
// Story resimleri tiklama ile genisleme ayari
struct statusView : View {
    
    var url = ""
    var name = ""
    
    var body : some View{
        
        ZStack{
            
            AnimatedImage(url: URL(string: url)).resizable()
            
            VStack{
                
                HStack{
                    
                    Text(name).font(.headline).fontWeight(.heavy).padding()
                    Spacer()
                }
                Spacer()
            }
        }
        
    }
}

