//
//  GithubUserService.swift
//  getGithub
//
//  Created by riiid on 2020/07/27.
//  Copyright © 2020 songzi. All rights reserved.
//

import Foundation
import SwiftGRPC

class GithubUserService {
    func getUsers() {
        let url = URL(string: "https://api.github.com/users/mojombo/repos")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
}
