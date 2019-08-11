//
//  IllustDetailViewController.swift
//  RetweetedIllustViewer
//
//  Created by 平山俊介 on 2018/09/25.
//  Copyright © 2018年 Shunsuke Hirayama. All rights reserved.
//

import UIKit

class IllustDetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var illust: UIImage? {
        didSet {
            initSubView()
        }
    }
    var imageView: UIImageView!
    
    var illustInfo: IllustInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        
        // navigationBarの設定
        self.navigationItem.title = illustInfo.name
        // フォントサイズを10に設定
        //        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
    }
    
    // Imageの読み込みが終了したら行う処理
    func initSubView() {
        imageView = UIImageView(image: illust)
        
        // タップに関する設定
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        
        let longTapGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.longTap(_:)))
        longTapGesture.delegate = self
        imageView.isUserInteractionEnabled = true  // 指定のviewをタップ可能にする
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.addGestureRecognizer(longTapGesture)
        
        // imageViewサイズの設定
        if let size = imageView.image?.size {
            // imageViewのサイズがscrollView内に収まるように調整
            let wrate = scrollView.frame.width / size.width
            let hrate = scrollView.frame.height / size.height
            let rate = min(wrate, hrate, 1)
            imageView.frame.size = CGSize(width: size.width * rate, height: size.height * rate)
            
            scrollView.contentSize = imageView.frame.size
            
            updateScrollInset()
        }
        scrollView.addSubview(imageView)
    }
    
    private func updateScrollInset() {
        // imageViewの大きさからcontentInsetを再計算
        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - imageView.frame.height)/2, 0),
            left: max((scrollView.frame.width - imageView.frame.width)/2, 0),
            bottom: 0,
            right: 0
        )
    }
    
    // ズーム可能にする
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // ズームのタイミングでcontentInsetを更新
        updateScrollInset()
    }
    
    // ダブルタップ時の処理
    @objc func doubleTap(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if (scrollView.zoomScale < scrollView.maximumZoomScale) {
                let newScale = scrollView.zoomScale * 3
                let zoomRect = self.zoomRectForScale(scale: newScale, center: sender.location(in: sender.view))
                
                scrollView.zoom(to: zoomRect, animated: true)
            } else {
                scrollView.setZoomScale(1.0, animated: true)
            }
        }
    }
    
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        let size = CGSize(
            width: scrollView.frame.size.width / scale,
            height: scrollView.frame.size.height / scale
        )
        return CGRect(
            origin: CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            ),
            size: size
        )
    }
    
    // ロングタップ時の処理
    @objc func longTap(_ sender: UITapGestureRecognizer){
        if sender.state == .began {
            let alert = createSaveAlert()
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func createSaveAlert() -> UIAlertController {
        let alert = UIAlertController(title: "画像を保存", message: "保存しますか？", preferredStyle: UIAlertController.Style.actionSheet)
        
        let okAction: UIAlertAction = UIAlertAction(title: "保存する", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.saveImage(image: self.illust, fileName: self.illustInfo.screenName+"_"+self.illustInfo.tweetId)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        return alert
    }
    
    // 画像の保存
    private func saveImage(image: UIImage?, fileName: String ) {
        guard let image = image else {
            print("画像取得失敗")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func tapTwitterButton(_ sender: Any) {
        // Chromeで開く場合はこっち
        //        let tweetUrlChrome = "googlechromes://mobile.twitter.com/\(illustInfo.screenName)/status/\(illustInfo.tweetId))"
        //        let tweetUrlChrome = tweetUrl.pregReplace(pattern: "https://", with: "googlechromes://")
        
        let tweetUrlTwitter = "twitter://status?id=\(illustInfo.tweetId)"
        
        guard let url = URL(string: tweetUrlTwitter) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /*
    // 遷移前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let twitterViewController = segue.destination as? TwitterViewController {
            let tweetUrl = "https://mobile.twitter.com/\(illustInfo.screenName)/status/\(illustInfo.tweetId))"
            twitterViewController.tweetUrl = tweetUrl
        }
    }
    */
}
