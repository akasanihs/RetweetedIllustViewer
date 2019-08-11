//
//  IllustCollectionViewController.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/24.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit

private let reuseIdentifier = "illustCell"

class IllustCollectionViewController: UICollectionViewController {
    
    // 遷移前に受け取る情報
    var entryUrl: String?
    var userUrl: String?
    var userName: String?
    
    
    private var viewModel: IllustCollectionViewModel!
    
    private var illustInfo: [IllustInfo] {
        return viewModel.illustInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel(order: "desc")
        viewModel.fetchIllustInfo()
    }
    
    private func initViewModel(order: String) {
        guard let unwrappedEntryUrl = entryUrl else { return }
        guard let unwrappedUserUrl = userUrl else { return }
        self.viewModel = IllustCollectionViewModel(entryUrl: unwrappedEntryUrl, userUrl: unwrappedUserUrl , order: order)
        
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
        
        return cell
        
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
