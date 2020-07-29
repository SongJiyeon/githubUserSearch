//
//  SearchGithubUserViewModel.swift
//  getGithub
//
//  Created by riiid on 2020/07/24.
//  Copyright © 2020 songzi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class SearchGithubUserViewModel: ObservableObject {
    
    var page = 1
    var firstFetch = false
    
    @Published var keyword = ""
    @Published private(set) var users = [UserForView]()
    
    private var subscriptions = Set<AnyCancellable>()
    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    init() {
        $keyword
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(
                receiveCompletion: { completion in print("🏀") },
                receiveValue: { keyword in
                    firstFetch = true
                    self.searchUser(keyword, self.page)
            }
        )
            .store(in: &subscriptions)
    }
    
    deinit {
        searchCancellable?.cancel()
    }
    
    func searchUser(_ keyword: String, _ page: Int) {
        guard !keyword.isEmpty else {
            return users = []
        }
        
        var urlComponents = URLComponents(string: "https://api.github.com/search/users")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(GITHUB_TOKEN)", forHTTPHeaderField: "Authorization")
        
        searchCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
            },
                receiveValue: {res in
                    res.forEach { user in
                        self.getUserReposCount(user)
                    }
            })
    }
    
    func getUserReposCount(_ user: User) {
        guard !user.login.isEmpty else {
            return
        }
        
        var urlComponents = URLComponents(string: "https://api.github.com")!
        urlComponents.path = "/users/\(user.login)"
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(GITHUB_TOKEN)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: UserForView.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in print(completion) },
                receiveValue: { user in
                    self.users.append(
                        UserForView(id: user.id, login: user.login, avatar_url: user.avatar_url, public_repos: user.public_repos)
                    )
            })
            .store(in: &subscriptions)
    }
}

struct SearchUserResponse: Decodable {
    var items: [User]
}
