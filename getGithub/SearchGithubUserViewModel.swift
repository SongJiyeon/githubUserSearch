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
    
    @Published var keyword = ""
    @Published private(set) var users = [UserForView]()
    @Published private(set) var images = [User: UIImage]()
    
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
                    self.searchUser(keyword)
                }
            )
            .store(in: &subscriptions)
    }
    
    deinit {
        searchCancellable?.cancel()
    }
    
    func searchUser(_ keyword: String) {
        guard !keyword.isEmpty else {
            return users = []
        }
        
        var urlComponents = URLComponents(string: "https://api.github.com/search/users")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: keyword)
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                    self.users = res.map { user in
                        UserForView(
                            id: user.id,
                            login: user.login,
                            avatar_url: user.avatar_url,
                            public_repos: self.getUserReposCount(username: user.login))
                    }
            })
    }
    
    func getUserReposCount(username: String) -> Int {
        guard !username.isEmpty else {
            return 0
        }
        
        var urlComponents = URLComponents(string: "https://api.github.com/users")!
        urlComponents.path = "/\(username)"
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        _ = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SearchUserReposResponse.self, decoder: JSONDecoder())
//            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in print(completion) },
                receiveValue: { res in print(res) })
            .store(in: &subscriptions)
        return 3
    }
}

struct SearchUserResponse: Decodable {
    var items: [User]
}

struct SearchUserReposResponse: Decodable {
    var public_repos: Int
}
