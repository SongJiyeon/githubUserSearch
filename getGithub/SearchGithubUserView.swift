//
//  ContentView.swift
//  getGithub
//
//  Created by riiid on 2020/07/24.
//  Copyright © 2020 songzi. All rights reserved.
//

import SwiftUI
import KingfisherSwiftUI

struct GithubUser: Identifiable {
    let id: Int
    let name: String
    let reposCount: Int
}

struct SearchGithubUserView: View {
    
    @State private var text: String = ""
    @State private var users: [GithubUser] = (1...50).map {
        GithubUser(id: $0, name: "user \($0)", reposCount: $0)
    }
    @ObservedObject var viewModel: SearchGithubUserViewModel = SearchGithubUserViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Enter github username", text: $viewModel.keyword)
                        .frame(width: 300)
                }
                .frame(width: 380)
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 2)
                        .padding([.leading, .trailing], 10)
                )
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.users) { user in
                            UserRow(viewModel: self.viewModel, user: user)
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

struct UserRow: View {
    
    @ObservedObject var viewModel: SearchGithubUserViewModel
    @State var user: UserForView
    
    var body: some View {
        HStack {
            KFImage(user.avatar_url)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text("\(user.login)")
                    .font(.system(size: 20))
                Spacer()
                    .frame(height: 5)
                Text("Number of repos: \(user.public_repos)")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 90)
    }
}

struct SearchGithubUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchGithubUserView()
    }
}
