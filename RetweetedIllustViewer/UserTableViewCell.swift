//
//  UserTableViewCell.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/21.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!  // ユーザー名のラベル
    @IBOutlet weak var userDateLabel: UILabel!  // ユーザーの更新日のラベル
    
    var userUrl: String?  // ユーザーの情報を返すJSONのURL。遷移先の画面で使用する
    var userName: String?  //ユーザーの名前。遷移先の画面で使用する
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
