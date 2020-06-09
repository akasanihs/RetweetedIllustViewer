//
//  IllustCollectionViewController.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/24.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit
import HeartButton

private let reuseIdentifier = "illustCell"

class IllustCollectionViewController: UICollectionViewController {
    
    
    // 遷移前に受け取る情報
    var entryUrl: String?
    var userUrl: String?
    var userName: String?
    
    @IBOutlet weak var r18StateButton: HeartButton!
    
    private var viewModel: IllustCollectionViewModel!
    
    private var illustInfo: [IllustInfo] {
        return viewModel.illustInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        r18StateButton.setOn(false, animated: false)
        r18StateButton.stateChanged = { sender, isOn in
            self.viewReload(r18State: isOn)
        }
        
        initViewModel(order: "desc", r18Disp: false)
        viewModel.fetchIllustInfo()
    }
    
    func viewReload(r18State: Bool) {
        initViewModel(order: "desc", r18Disp: r18State)
        viewModel.fetchIllustInfo()
    }
    
    private func initViewModel(order: String, r18Disp: Bool) {
        guard let unwrappedEntryUrl = entryUrl else { return }
        guard let unwrappedUserUrl = userUrl else { return }
        self.viewModel = IllustCollectionViewModel(entryUrl: unwrappedEntryUrl, userUrl: unwrappedUserUrl , order: order, r18Disp: r18Disp)
        
        // ハンドラの設定
        viewModel.reloadHandler = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.initHandler = { [weak self] in
            // イラスト件数を取得
            if let unwrappedIllustSize = self?.viewModel.illustSize {
                // ナビゲーションバーのタイトルを設定
                self?.navigationItem.title = (self?.userName ?? "Unkown") + " (\(String(unwrappedIllustSize))件)"
            }
        }
        
        viewModel.errorHandler = { [weak self](alert: UIAlertController) in
            self?.present(alert, animated: true, completion: nil)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    // cellの数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return illustInfo.count
    }
    
    // cellの内容を設定
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cellの取得
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IllustCollectionViewCell
        
        // illustInfoからcellに設定する画像のURLを取得
        let info = illustInfo[indexPath.row]
        let illustUrl = info.illustUrl
        
        // 画像を取得してセルに設定
        viewModel.getThumbnailImage(illustUrl: illustUrl, cell: cell)
        
        // cellに遷移用の情報を保存
        cell.illustInfo = info
        
        // r18ボタンの状態を反映
        if (info.r18){
            cell.r18Button.setOn(true, animated: false)
        }else{
            cell.r18Button.setOn(false, animated: false)
        }
        
        // r18ボタンが押された時の処理
        // TODO: ここに書かない方がいいかも？
        cell.r18Button.stateChanged = { sender, isOn in
            if isOn {
                print("on")
                self.updateR18State(true, tweetID: cell.illustInfo.tweetId, page: String(cell.illustInfo.page))
            } else {
                print("off")
                self.updateR18State(false, tweetID: cell.illustInfo.tweetId, page: String(cell.illustInfo.page))
            }
        }
        
        
        return cell
        
    }
    
    // R18切り替えAPIを叩く
    // TODO: エラー処理
    func updateR18State(_ state:Bool, tweetID:String, page:String) {
        guard let unwrappedEntryUrl = entryUrl else { return }
        let updateR18Url = state ? "/r18/create" : "/r18/destroy"
            
        guard let url: URL = URL(string: unwrappedEntryUrl + updateR18Url) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params:[String:String] = [
            "tweet_id": tweetID,
            "page": page
        ]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print("result:\(resultData)")
//                print("response:\(String(describing: response))")

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
        
    }
    
    
    // スクロールした時の処理(下にスクロールしたらAPIを叩く)
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 500 {
            viewModel.fetchIllustInfo()
        }
    }
    
    // 遷移前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? IllustCollectionViewCell {
            if let illustDetailViewController = segue.destination as? IllustDetailViewController {
                viewModel.getOriginalImage(illustUrl: cell.illustInfo.illustUrl, illustDetailViewController: illustDetailViewController)
                illustDetailViewController.illustInfo = cell.illustInfo
            }
        }
    }

}

// レイアウト設計
extension IllustCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 横方向のスペース調整
        let horizontalSpace:CGFloat = 1
        let cellSize:CGFloat = floor(self.view.bounds.width/2) - horizontalSpace

        return CGSize(width: cellSize, height: cellSize)
    }
}
