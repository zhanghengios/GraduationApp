//
//  BlockedUserVC.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/12/13.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class BlockedUserVC: UIViewController {
    
    let viewModel = BlockedUserViewModel()
    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableViewSetting()
        
        self.viewModel.blockedUserMapRelay
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.currentStateRelay
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                switch value {
                case .none:
                    break
                    
                case .complete:
                    
                    let alert = AlertController(title: "차단이 해제되었습니다", message: "", preferredStyle: .alert)
                    alert.setTitleImage(UIImage(named: "alertComplete"))
                    let action = UIAlertAction(title: "확인", style: .default) { action in
                        print("차단 완료 했으므로 테이블뷰 초기화")
                        self?.viewModel.getBlockedUserList()
                        self?.viewModel.currentStateRelay.accept(.none)
                    }
                    action.setValue(UIColor.appColor(.green2), forKey: "titleTextColor")
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                    
                    break
                    
                case .fail:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - TableView

extension BlockedUserVC: UITableViewDelegate, UITableViewDataSource {
    func tableViewSetting() {
        tableView.rowHeight = 74
        
        // Empty Xib 설정, DPTI를 안했을 경우, 그리고 결과값이 없을 경우에 해당
        let nibName = UINib(nibName: "EmptyTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "EmptyTableViewCell")
        
        let loadingNibName = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.register(loadingNibName, forCellReuseIdentifier: "LoadingTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 콘텐츠 준비 중이라는 셀을 띄울 것
        if self.viewModel.blockedUserMapRelay.value.count == 0 {
            return 1
        }
        
        return self.viewModel.blockedUserMapRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.blockedUserMapRelay.value.count == 0 && viewModel.loadingRelay.value == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
            cell.settingImageSizeLabel(cellKinds: .blockUser, text: "차단한 유저가 없어요")
            tableView.rowHeight = 375
            return cell
        }
        
        if viewModel.blockedUserMapRelay.value.count == 0 && viewModel.loadingRelay.value == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath)
            return cell
        }
        
        // 차단한 유저가 있을 경우
        tableView.rowHeight = 74
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath) as! BlockedUserCell
        
        let index = indexPath.row
        let model = self.viewModel.blockedUserMapRelay.value
        
        cell.index = index
        cell.delegate = self
        
        if let Uid = model[index].uid {
            cell.Uid = Uid
        }
        
        if let nickname = model[index].nickname {
            cell.blockedUserNickname.text = "\(nickname)"
        }
        
        if let type = model[index].type {
            cell.blockedUserProfileImageView.image = UIImage(named: "Profile_\(type)")
            cell.blockedUserNickname.textColor = UIColor.dptiDarkColor("\(type)")
        }
        
        return cell
    }
    
    
}

extension BlockedUserVC: BlockCellPressedCancelBtnDelegate {
    func pressedCancleBtnInCell(index: Int, userUid: String) {
        
        let alert = AlertController(title: "차단을 해제하시겠습니까?", message: "", preferredStyle: .alert)
        alert.setTitleImage(UIImage(named: "alertError"))
        let action = UIAlertAction(title: "확인", style: .destructive) { action in
            print("차단 진짜할거잉")
            self.viewModel.cancleBlockUser(userUID: userUid)
        }
        let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        alert.addAction(action)
        alert.addAction(cancleAction)
        present(alert, animated: true, completion: nil)
        
        print("전달 받았습니다 Index: \(index), userUID: \(userUid)")
    }
}
