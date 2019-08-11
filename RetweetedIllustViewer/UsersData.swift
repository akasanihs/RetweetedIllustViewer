//
//  UsersData.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/21.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

class UsersData: Codable {
    var size: Int
    var page: Int
    var maxPage: Int
    var hasNext: Bool
    var usersInfo: [UsersInfo] = [UsersInfo]()
    
    private enum CodingKeys: String, CodingKey {
        case size
        case page
        case maxPage = "max_page"
        case hasNext = "has_next"
        case usersInfo = "users_info"
    }
}

class UsersInfo: Codable {
    var screenName: String
    var name: String
    var lastUpdateTime: String
    var userUrl: String
    
    // 全ユーザー用のイニシャライザ
    init(name: String, userUrl: String) {
        self.screenName = ""
        self.name = name
        self.lastUpdateTime = ""
        self.userUrl = userUrl
    }
    
    private enum CodingKeys: String, CodingKey {
        case screenName = "screen_name"
        case name
        case lastUpdateTime = "last_update_time"
        case userUrl = "user_url"
    }
}
