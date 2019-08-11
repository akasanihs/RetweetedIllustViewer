//
//  SearchUserTableViewController.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/21.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit

private let reuseIdentifier = "userCell"

class SearchUserTableViewController: UITableViewController {
    
    private var viewModel = SearchUserTableViewModel()
    
    private var usersInfo: [UsersInfo] {
        return viewModel.usersInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        viewModel.fetchUsersInfo()
        initTableView()
        }

    private func initViewModel() {
        // ViewModelのクロージャーにテーブルのリロードを設定
        // usersInfoの値がセットされた後にこれを呼びテーブルの再表示を行う
        viewModel.reloadHandler = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.initHandler = { [weak self] in
            // ユーザー件数を取得
            if let unwrappedUserSize = self?.viewModel.userSize {
                // ナビゲーションバーのタイトルを設定
                if let unwrappedSearchWord = self?.viewModel.searchWord {
                    self?.navigationItem.title = unwrappedSearchWord + " (\(String(unwrappedUserSize))件)"
                }else{
                    self?.navigationItem.title = "全てのユーザー" + " (\(String(unwrappedUserSize))件)"
                }
            }
        }
        
        viewModel.errorHandler = { [weak self](alert: UIAlertController) in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func initTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // cellの数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersInfo.count
    }
    
    // cellの内容を設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cellの取得
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        // usersInfoからcellに設定する値を取得
        let userInfo = usersInfo[indexPath.row]
        
        // cellのプロパティを設定
        var nameLabel = userInfo.name
        if !(userInfo.screenName=="") {
            nameLabel += " @" + userInfo.screenName
        }
        cell.userNameLabel.text = nameLabel
        cell.userDateLabel.text = userInfo.lastUpdateTime
        cell.userUrl = userInfo.userUrl
        cell.userName = userInfo.name
        return cell
    }
    
    // スクロールした時の処理(下にスクロールしたらAPIを叩く)
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 500 {
            viewModel.fetchUsersInfo()
        }
    }
    
    // 遷移前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UserTableViewCell {
            if let illustCollectionViewController = segue.destination as? IllustCollectionViewController {
                illustCollectionViewController.entryUrl = SearchUserTableViewModel.entryUrl
                illustCollectionViewController.userUrl = cell.userUrl
                illustCollectionViewController.userName = cell.userName
            }
        }
    }
    // セルがタップされた時の処理
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = UIStoryboard(name: "ArticleDetail", bundle: nil).instantiateInitialViewController()! as! ArticleDetailViewController
//        vc.article = articles[indexPath.row]
//        navigationController?.pushViewController(vc, animated: true)
//    }
    

}

// 検索バーの処理を追加
extension SearchUserTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let inputText = searchBar.text else {
            return
        }
        
        // 検索ワードがなかったら、全ユーザー表示に戻す
        if inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            viewModel = SearchUserTableViewModel(searchWord: inputText)
        }else{
            viewModel = SearchUserTableViewModel()
        }
        
        initViewModel()
        
        // APIを叩く
        viewModel.fetchUsersInfo()
        
        // キーボードを閉じる
        searchBar.resignFirstResponder()
    }
}
