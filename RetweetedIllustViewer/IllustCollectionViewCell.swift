//
//  IllustCollectionViewCell.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/24.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit

class IllustCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var illustImageView: UIImageView!

    var illustInfo: IllustInfo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        // cellの枠の太さ
//        self.layer.borderWidth = 1.0
        // cellの枠の色
//        self.layer.borderColor = UIColor.black.cgColor
        // cellを丸くする
//        self.layer.cornerRadius = 10.0
    }
    
    
    override func prepareForReuse() {
        illustImageView.image = nil
    }
}
