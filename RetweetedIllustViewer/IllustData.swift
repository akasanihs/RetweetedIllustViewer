//
//  IllustData.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/21.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

class IllustData: Codable {
    var size: Int
    var page: Int
    var maxPage: Int
    var hasNext: Bool
    var illustInfo: [IllustInfo] = [IllustInfo]()
    
    private enum CodingKeys: String, CodingKey {
        case size
        case page
        case maxPage = "max_page"
        case hasNext = "has_next"
        case illustInfo = "illust_info"
    }
}

class IllustInfo: Codable {
    var screenName: String
    var name: String
    var tweetId: String
    var page: Int
    var createdTime: String
    var illustUrl: String
    var r18: Bool
    
    private enum CodingKeys: String, CodingKey {
        case screenName = "screen_name"
        case name
        case tweetId = "tweet_id"
        case page
        case createdTime = "created_time"
        case illustUrl = "illust_url"
        case r18
    }
}
