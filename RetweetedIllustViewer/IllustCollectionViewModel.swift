//
//  IllustCollectionViewModel.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/24.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import Foundation
import UIKit

class IllustCollectionViewModel {
    
    enum LoadStuts {
        case initial
        case fetching
        case full
        case loadmore
    }
    
    let entryUrl: String!
    let userUrl: String!
    let order: String
    let r18Disp: Bool!
    private var page: Int = 1
    private var loadStatus: LoadStuts = .initial
    var illustSize: Int? {
        didSet {
            initHandler()
        }
    }
    
    var illustInfo: [IllustInfo] = [] {
        // 値がセットされると実行される
        didSet {
            reloadHandler()
        }
    }
    
    var imageCache = NSCache<AnyObject, UIImage>()
    
    var reloadHandler: () -> Void = {}
    var initHandler: () -> Void = {}
    var errorHandler: ((UIAlertController) -> Void)?
    
    // イニシャライザ
    init(entryUrl: String, userUrl: String, order: String, r18Disp: Bool) {
        self.entryUrl = entryUrl
        self.userUrl = userUrl
        self.order = order
        self.r18Disp = r18Disp
    }
    
    func fetchIllustInfo() {
        print(self.loadStatus)
        // 読み込み中またはもう次にイラストがない場合にはapiを叩かないようにする
        guard loadStatus != .fetching && loadStatus != .full else { return }
        
        // loadStatusを読み込み中に変更
        loadStatus = .fetching
        
        // APIのURL
        guard let url: URL = URL(string: entryUrl + userUrl) else { return }
        
        // クエリを設定
        let query = [URLQueryItem(name: "page", value: String(page)),
                     URLQueryItem(name: "order", value: self.order),
                     URLQueryItem(name: "r18", value: String(self.r18Disp))]
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
                let result = try JSONDecoder().decode(IllustData.self, from: data)
                
                
                DispatchQueue.main.async() { () -> Void in
                    if self.illustSize == nil {
                        self.illustSize = result.size
                    }
                    self.illustInfo.append(contentsOf:result.illustInfo)
                    
                    // 次のpageがあるかをチェック
                    if !(result.hasNext) {
                        self.loadStatus = .full
                    } else {
                        self.loadStatus = .loadmore
                    }
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
    
    // サムネ画像の取得
    func getThumbnailImage(illustUrl: String, cell: IllustCollectionViewCell) {
        
        let noImage:UIImage? = UIImage(named:"no_image")
        
        // キャッシュから画像を取得
        if let cacheImage = imageCache.object(forKey: illustUrl as AnyObject) {
            cell.illustImageView.image = cacheImage
            return
        }
        
        // キャッシュから画像を取得できなかったらダウンロードする
        // URLを生成
        guard let url = URL(string: entryUrl + illustUrl) else {
            // URL生成失敗
            cell.illustImageView.image = noImage
            return
        }
        
        // クエリを追加
        let query = [URLQueryItem(name: "size", value: "thumbnail")]
        guard let queryStringAddedUrl = url.queryItemsAdded(query) else {
            cell.illustImageView.image = noImage
            return
        }
        
        
        let task: URLSessionTask  = URLSession.shared.dataTask(with: queryStringAddedUrl) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                cell.illustImageView.image = noImage
                return
            }
            
            guard let data = data else {
                cell.illustImageView.image = noImage
                return
            }
            
            guard let image = UIImage(data: data) else {
                cell.illustImageView.image = noImage
                return
            }
            
            self.imageCache.setObject(image, forKey: illustUrl as AnyObject)
            DispatchQueue.main.async {
                cell.illustImageView.image = image
            }
        }
        task.resume()
        
        return
    }
    
    // オリジナル画像の取得
    func getOriginalImage(illustUrl: String, illustDetailViewController: IllustDetailViewController) {
        
        let noImage:UIImage? = UIImage(named:"no_image")
        
        // URLを生成
        guard let url = URL(string: entryUrl + illustUrl) else {
            // URL生成失敗
            illustDetailViewController.illust = noImage
            return
        }
        
        // クエリを追加
        let query = [URLQueryItem(name: "size", value: "original")]
        guard let queryStringAddedUrl = url.queryItemsAdded(query) else {
            illustDetailViewController.illust = noImage
            return
        }
        
        
        let task: URLSessionTask  = URLSession.shared.dataTask(with: queryStringAddedUrl) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                illustDetailViewController.illust = noImage
                return
            }
            
            guard let data = data else {
                illustDetailViewController.illust = noImage
                return
            }
            
            guard let image = UIImage(data: data) else {
                illustDetailViewController.illust = noImage
                return
            }
            
            DispatchQueue.main.async {
                illustDetailViewController.illust = image
            }
        }
        task.resume()
        
        return
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
