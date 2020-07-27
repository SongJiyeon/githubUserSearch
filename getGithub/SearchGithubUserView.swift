//
//  ContentView.swift
//  getGithub
//
//  Created by riiid on 2020/07/24.
//  Copyright © 2020 songzi. All rights reserved.
//

import SwiftUI

struct GithubUser: Identifiable {
    let id: Int
    let name: String
    let reposCount: Int
}

struct ContentView: View {
    
    let apiService = GithubUserService()
    
    @State private var text: String = ""
    @State private var users: [GithubUser] = (1...50).map {
        GithubUser(id: $0, name: "user \($0)", reposCount: $0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Button("click") {
                    self.apiService.getUsers()
                }
                TextField("Enter github username", text: $text)
                    .padding([.leading, .trailing], 30)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 2)
                            .padding([.leading, .trailing], 10)
                    )
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(users) { user in
                            SearchResult(name: user.name, reposCount: user.reposCount)
                            Divider()
                        }
                        .padding([.leading, .trailing], 15)
                    }
                }
            }
            .navigationBarTitle(Text("Github Users"))
        }
    }
}

struct SearchResult: View {
    
    var name: String
    var reposCount: Int
    
    var body: some View {
        HStack {
            Image("github-empty")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text("\(name)")
                    .font(.system(size: 20))
                Spacer()
                    .frame(height: 5)
                Text("Number of repos: \(reposCount)")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 90)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
