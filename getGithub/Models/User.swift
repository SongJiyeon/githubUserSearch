//
//  User.swift
//  getGithub
//
//  Created by riiid on 2020/07/28.
//  Copyright © 2020 songzi. All rights reserved.
//

import Foundation

struct User: Hashable, Identifiable, Decodable {
    var id: Int64
    var login: String
    var avatar_url: URL?
}
