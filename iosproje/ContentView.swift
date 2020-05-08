//
//  ContentView.swift
//  iosproje
//
//  Created by Canberk BİBİCAN on 24.04.2020.
//  Copyright © 2020 Canberk BİBİCAN. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FirstPage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FirstPage : View {
    
    @State var no = "second commit"
    
    var body : some View{
        VStack(spacing: 20){
            Image("pic")
            
            Text("Verify Your Number").font(.largeTitle).fontWeight(.heavy)
            
            Text("Please Enter Your Number To Verify Your Account").font(.body).foregroundColor(.gray).padding(.top, 12)
            
            TextField("Number", text: $no)
            .padding()
            .background(Color("Color"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button(action:{
                
            }) {
                
                Text("Send").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                
                }.foregroundColor(.white).background(Color.orange).cornerRadius(10)
        }
    }
}
