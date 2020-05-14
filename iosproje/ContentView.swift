
//  ContentView.swift
//  iosproje
//
//  Created by Canberk BİBİCAN on 24.04.2020.
//  Copyright © 2020 Canberk BİBİCAN. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import GoogleSignIn


// ---------------------------------------------- CONTENT VIEW
// TOP NAVIGATION BAR

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        
        VStack{
            
            if status{
                
                homePage()
            }
            else{
                
                Login()
            }
            
        }.animation(.spring())
        .onAppear {
                
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
                
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
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

struct homePage : View {
    
    var body : some View{
        
        TabView{
            
            NavigationView{
                        
                Home()
                            .navigationBarTitle("Instagram")
                            .navigationBarItems(leading: Button(action: {
                                
                            }, label: {
                                
                                Image("instalogo").resizable().frame(width: 30, height: 30)
                                
                            })
                                .foregroundColor(Color("darkAndWhite"))
                                , trailing:
                                
                                HStack{
                                    
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
                    
                    Text("Upload").tabItem {
                        
                        Image("plus")
                    }
                    Profile().tabItem {
                        
                        Image("people")
                    }
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

struct Login : View {
    
    @State var user = ""
    @State var pass = ""
    @State var msg = ""
    @State var alert = false
    
    var body : some View{
        
        VStack{
            
            Image("instalogo").frame(width: 70, height: 70)
            
            Text("Sign In").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
            
            VStack(alignment: .leading){
                
                VStack(alignment: .leading){
                    
                    Text("Email").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                    
                    HStack{
                        
                        TextField("Enter Your Email", text: $user)
                        
                        if user != ""{
                            
                            Image("check").foregroundColor(Color.init(.label))
                        }
                        
                    }
                    
                    Divider()
                    
                }.padding(.bottom, 15)
                
                VStack(alignment: .leading){
                    
                    Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                    SecureField("Enter Your Password", text: $pass)
                    
                    Divider()
                }

            }.padding(.horizontal, 6)
            
            Button(action: {
                
                signInWithEmail(email: self.user, password: self.pass) { (verified, status) in
                    
                    if !verified{
                        
                        self.msg = status
                        self.alert.toggle()
                    }
                    else{
                        
                        UserDefaults.standard.set(true, forKey: "status")
                        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                    }
                }
                
            }) {
                
                Text("Sign In").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
                
                
            }.background(Color("Color"))
            .clipShape(Capsule())
            .padding(.top, 25)
            
            bottomView()
            
        }.padding()
        .alert(isPresented: $alert) {
                
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}

struct bottomView : View{
    
    @State var show = false
    
    var body : some View{
        
        VStack{
            
            Text("(or)").foregroundColor(Color.gray.opacity(0.5)).padding(.top,30)
            
            GoogleSignView().frame(width: 150, height: 55)
            
            HStack(spacing: 8){
                
                Text("Don't Have An Account ?").foregroundColor(Color.gray.opacity(0.5))
                
                Button(action: {
                    
                    self.show.toggle()
                    
                }) {
                    
                   Text("Sign Up")
                    
                }.foregroundColor(.blue)
                
            }.padding(.top, 25)
            
        }.sheet(isPresented: $show) {
            
            Signup(show: self.$show)
        }
    }
}

struct Signup : View {
    
    @State var user = ""
    @State var pass = ""
    @State var alert = false
    @State var msg = ""
    @Binding var show : Bool
    
    var body : some View{
        
        VStack{
            
            Image("instalogo")
                
                Text("Sign Up").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
                
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading){
                        
                        Text("Email").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                        HStack{
                            
                            TextField("Enter Your Email", text: $user)
                            
                            if user != ""{
                                
                                Image("check").foregroundColor(Color.init(.label))
                            }
                            
                        }
                        
                        Divider()
                        
                    }.padding(.bottom, 15)
                    
                    VStack(alignment: .leading){
                        
                        Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                            
                        SecureField("Enter Your Password", text: $pass)
                        
                        Divider()
                    }

                }.padding(.horizontal, 6)
                
                Button(action: {
                    
                    signIupWithEmail(email: self.user, password: self.pass) { (verified, status) in
                        
                        if !verified{
                            
                            self.msg = status
                            self.alert.toggle()
                            
                        }
                        else{
                            
                            UserDefaults.standard.set(true, forKey: "status")
                            
                            self.show.toggle()
                            
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }
                    }
                    
                }) {
                    
                    Text("Sign Up").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
                    
                    
                }.background(Color("Color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            
        }.padding()
        .alert(isPresented: $alert) {
                
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}

struct GoogleSignView : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<GoogleSignView>) -> GIDSignInButton {
        
        let button = GIDSignInButton()
        button.colorScheme = .dark
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        return button
        
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: UIViewRepresentableContext<GoogleSignView>) {
        
        
    }
}

func signInWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}

func signIupWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
    
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}
/*      ------------------------------     https://www.youtube.com/watch?v=zfJtgq609EE     dakika 8.37       -------------------------------
struct sharedPage : View {
    @State var shown = false
    
    var body : some View{
        
        Button(action: {
            
            self.shown.toggle()
            
        }) {
            
            Text("upload İmage")
            
        }.sheet(isPressented: $shown){
            
            imagePicker(shown: $shown)
        }
    }
}

struct imagePicker : UIViewControllerRepresentable{
    func makeCoordinator() -> imagePicker.Coordinator {
        
        
        return imagePicker.Coordinator(parent1 : self)
    }
    
    
    @Binding var shown : Bool
    @Binding var data : Data
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<imagePicker>) -> UIImagePickerController{
        
        let imagepic = UIImagePickerController()
        imagepic.sourceType = .photoLibrary
        return imagepic
        
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<imagePicker>) {
        
    }
    class Coordinator : NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        
        var parent : imagePicker!
        init(parent1 : imagePicker){
            
            parent = parent1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
            parent.shown.toggle()
            
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            parent.data = image.jpegData(compressionQuality: 0.35)
            
        }
    }
}
*/
struct Profile : View {
    var body : some View{
        Button(action: {
            
            
            try! Auth.auth().signOut()
            GIDSignIn.sharedInstance()?.signOut()
            UserDefaults.standard.set(false, forKey: "status")
            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            
        }) {
            
            Text("Logout")
        }
    }
}
