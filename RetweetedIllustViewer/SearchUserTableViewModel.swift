//
//  SearchUserTableViewModel.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/21.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import Foundation
import UIKit

class SearchUserTableViewModel {
    
    enum LoadStuts {
        case initial
        case fetching
        case full
        case loadmore
    }
    
    // TODO: URLの設定
    static let entryUrl = "http://akasanihs.ddns.net:5555"
//    static let entryUrl = "http://192.168.0.17:5555"
    private var page: Int = 1
    private var loadStatus: LoadStuts = .initial
    var searchWord: String?
    var userSize: Int? {
        didSet {
            initHandler()
        }
    }
    
    var usersInfo: [UsersInfo] = [UsersInfo(name: "全てのイラスト", userUrl: "/illust")] {
        // 値がセットされると実行される
        didSet {
            reloadHandler()
        }
    }
    
    var reloadHandler: () -> Void = {}
    var initHandler: () -> Void = {}
    var errorHandler: ((UIAlertController) -> Void)?
    // イニシャライザ
    init() { }
    init(searchWord: String) {
        self.searchWord = searchWord
    }
    
    func fetchUsersInfo() {
        // 読み込み中またはもう次に記事がない場合にはapiを叩かないようにする
        guard loadStatus != .fetching && loadStatus != .full else { return }
        
        // loadStatusを読み込み中に変更
        loadStatus = .fetching
        
        // APIのURL
        guard let url: URL = URL(string: SearchUserTableViewModel.entryUrl + "/users") else { return }
        
        // クエリを設定
        var query = [URLQueryItem(name: "page", value: String(page))]
        if let unwrappedSearchWord = searchWord {
            query.append(URLQueryItem(name: "word", value: unwrappedSearchWord))
        }
        guard let queryStringAddedUrl = url.queryItemsAdded(query) else { return }
        
        let task: URLSessionTask  = URLSession.shared.dataTask(with: queryStringAddedUrl, completionHandler: {data, response, error in
            do {
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.errorHandler!(self.createErrorAlert(errorMessage: error?.localizedDescription ?? "リクエスト時にエラーが発生しました。"))  // ハンドラーでControllerに渡す
                    }
                    return
                }
                
                guard let data = data else { return }
                
                // パース実施
                let result = try JSONDecoder().decode(UsersData.self, from: data)
                
                
                DispatchQueue.main.async() { () -> Void in
                    if self.userSize == nil {
                        self.userSize = result.size
                    }
                    self.usersInfo.append(contentsOf:result.usersInfo)
                    self.loadStatus = .loadmore // 記事取得が終わった段階でloadStatusをloadmoreにする
                }
                
                // 次のpageがあるかをチェック
                if !(result.hasNext) {
                    self.loadStatus = .full //もう続きの記事がないときにはloadStatusをfullにする
                }
                self.page += 1
                
            }
            catch let error{
                print(String(describing: type(of: error)))
                
                print("EEEEE")
                print(error)
                
                // UIに関する処理はメインスレッドで行う
                DispatchQueue.main.async {
                    self.errorHandler!(self.createErrorAlert(errorMessage: error.localizedDescription))  // ハンドラーでControllerに渡す
                }
            }
            
        })
        task.resume()
    }
    
    // エラーメッセージを受け取り、アラートを作成
    private func createErrorAlert(errorMessage: String) -> UIAlertController {
        // エラー表示するためのアラートを作成
        let alert = UIAlertController(title: "エラー", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        alert.addAction(defaultAction)
        
        return alert
    }
    
}
