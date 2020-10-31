//
//  CommunitySearchVC.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/10/30.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxRelay

protocol  SendSearchTextDelegate {
    func send(keyword: String)
}

class CommunitySearchVC: UIViewController {

//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldRoundView: UIView! {
        didSet {
            textFieldRoundView.layer.cornerRadius = 20
            textFieldRoundView.layer.borderWidth = 1.7
            textFieldRoundView.layer.borderColor = UIColor.appColor(.gray190).cgColor
            textFieldRoundView.layer.masksToBounds = true
        }
    }
//    @IBOutlet weak var recommendCollectionView: UICollectionView!
//
//    @IBOutlet weak var recommendView: UIView!
//    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var resultContainerView: UIView! {
        didSet {
            resultContainerView.isHidden = true
        }
    }
    @IBOutlet weak var textField: UITextField!
    
    var disposeBag = DisposeBag()
    var communitySearchResultVC: CommunitySearchResultVC?
    var sendKeywordDelegate: SendSearchTextDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
//        tableView.dataSource = self
        
        
//        recommendCollectionView.delegate = self
//        recommendCollectionView.dataSource = self
        
        textField.rx.text.orEmpty
            .map { $0 as! String }
            .subscribe(onNext: {
                
            })
            .disposed(by: disposeBag)
    }
    
    func searchResult() {
        if communitySearchResultVC == nil {
            let vc = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunitySearchResultVC") as! CommunitySearchResultVC
            
            if let text = textField.text {
                vc.keyword = text
            }
            
            let topMargin: CGFloat = 88
            let searchAreaHeight: CGFloat = textFieldRoundView.frame.height + topMargin
            
            vc.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - searchAreaHeight)
            vc.willMove(toParent: self)
            resultContainerView.addSubview(vc.view)
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            communitySearchResultVC = vc
        } else {
            communitySearchResultVC!.keyword = textField.text!
        }
        
        
        print(communitySearchResultVC)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "CommunityResultVC" {
//            let destinationVC = segue.destination as! CommunitySearchResultVC
//            destinationVC.SendKeywordDelegate = SendKeywordDelegate
//        }
        
        if segue.identifier == "SearchPageVC" {
            let vc = segue.destination as! SearchPageVC
            let articleSearchVC = vc.VCArray[0] as! ArticleSearchVC
            
            sendKeywordDelegate = articleSearchVC
        }
    }
    

    @IBAction func pressedSearchBtn(_ sender: Any) {
//        recommendView.isHidden = true
//        historyView.isHidden = true
        resultContainerView.isHidden = false
        
        
        if let text = textField.text {
            sendKeywordDelegate?.send(keyword: "\(text)")
        }
        
        print("검색")
    }
    
    @IBAction func pressedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - TableView

extension CommunitySearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(40)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunitySearchHistoryCell", for: indexPath)

        return cell
    }
    
    
}

// MARK: -recommendCollectionView

extension CommunitySearchVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityRecommendCell", for: indexPath)
        
        return cell
    }
    
    
}
