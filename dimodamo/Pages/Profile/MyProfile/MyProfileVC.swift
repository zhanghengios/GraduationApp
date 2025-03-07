//
//  MyProfileVC.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/06.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

enum MyProfileMoreBtn: Int {
    case like = 0
    case scrap = 1
    case heart = 2
}

class MyProfileVC: UIViewController {
    
    let viewModel = MyProfileViewModel()
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView! {
        didSet {
//            bottomContainer.layer.cornerRadius = 24
//            bottomContainer.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var topStretchBG: UIView!
    @IBOutlet weak var backgroundPattern: UIImageView!
    @IBOutlet weak var bubblePopup: UIImageView!
    @IBOutlet weak var menuBtn: UIButton! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    /*
     ProfileContainer
     */
    @IBOutlet weak var profileBG: UIView! {
        didSet {
            profileBG.layer.cornerRadius = profileBG.frame.height / 2
            profileBG.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var type: UIImageView!
    @IBOutlet weak var registerDate: UILabel!
    @IBOutlet weak var commentHeartIcon: UIImageView!
    @IBOutlet weak var commentHeartCountLabel: UILabel!
    @IBOutlet weak var scrapIcon: UIImageView!
    @IBOutlet weak var scrapCountLabel: UILabel!
    @IBOutlet weak var manitoIcon: UIImageView!
    @IBOutlet weak var manitoGoodCountLabel: UILabel!
    
    @IBOutlet weak var messageBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBtn: UIButton! {
        didSet {
//            messageBtn.layer.cornerRadius = 12
//            messageBtn.layer.masksToBounds = true
        }
    }
    /*
     Tags
     */
    @IBOutlet var tags: [UILabel]! {
        didSet {
            for tag in tags {
                tag.layer.borderWidth = 1.5
                tag.layer.borderColor = UIColor.appColor(.system).cgColor
                tag.layer.cornerRadius = tag.frame.height / 2
                tag.layer.masksToBounds = true
                
                tag.widthAnchor.constraint(equalToConstant: 73).isActive = true
                tag.textAlignment = .center
                tag.attributedText = NSAttributedString.init(string: "안녕", attributes: [NSAttributedString.Key.baselineOffset : -1])
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        setColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.prefersLargeTitles = true
        animate()

    }
    
    private func animate() {
        guard let coordinator = self.transitionCoordinator else {
            return
        }
        
        coordinator.animate(alongsideTransition: {
            [weak self] context in
            self?.setColors()
        }, completion: nil)
    }
    
    private func setColors() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.dptiDarkColor(viewModel.profileSetting.value)
//        navigationController?.navigationBar.barTintColor = UIColor.clear
//        navigationController?.navigationBar.backgroundColor = UIColor.clear
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Profile 컬러 및 도형 위주로 세팅
         */
        viewModel.profileSetting
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] typeString in
                
                guard let userNickname = self?.viewModel.userNickname else {
                    return
                }
                
                // 정상적으로 값이 들어오는 경우
                if typeString != "" {
                    self?.nicknameLabel.text = "\(userNickname)"
                    self?.profile.image = UIImage(named: "Profile_\(typeString)")
                    self?.type.image = UIImage.dptiProfileTypeIcon(typeString, isFiiled: false)
                    self?.topContainer.backgroundColor = UIColor.dptiDarkColor(typeString)
                    self?.topStretchBG.backgroundColor = UIColor.dptiDarkColor(typeString)
                    self?.backgroundPattern.image = UIImage.shapeBackgroundPattern(typeString)
                } else {
                    
                }
            })
            .disposed(by: disposeBag)
        
        
        /*
         정량적 데이터
         */
        viewModel.userProfileData
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                
                
                self?.commentHeartIcon.image = MedalKinds.getMedal(kind: .comment, commentHeartCount: data.commentHeartCount, manitoGoodCount: data.manitoGoodCount, documnetScrapCount: data.scrapCount)
                self?.commentHeartCountLabel.text = "+\(data.commentHeartCount)"
                
                self?.scrapIcon.image = MedalKinds.getMedal(kind: .scrap, commentHeartCount: data.commentHeartCount, manitoGoodCount: data.manitoGoodCount, documnetScrapCount: data.scrapCount)
                self?.scrapCountLabel.text = "+\(data.scrapCount)"
                
                self?.manitoIcon.image = MedalKinds.getMedal(kind: .manito, commentHeartCount: data.commentHeartCount, manitoGoodCount: data.manitoGoodCount, documnetScrapCount: data.scrapCount)
                self?.manitoGoodCountLabel.text = "+\(data.manitoGoodCount)"
                self?.registerDate.text = "\(data.createdAt)"
                
                for (index, tag) in self!.tags.enumerated() {
                    tag.text = "\(data.interests[index])"
                    tag.text = "\(Interest.getWordFromString(from: data.interests[index]))"
                }
                
                // 내 프로필일 경우에 쪽지 보내기 비활성화
                if self?.viewModel.isMyProfile() == true {
                    self?.menuBtn.isHidden = true
//                    self?.messageBtn.isHidden = true
                    self?.messageBtnHeightConstraint.constant = 0
                } else {
//                    self?.messageBtn.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        /*
         차단이 완료되면 Alert을 띄우는 용도
         */
        viewModel.isBlockedUser
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                if value == .blockComplete {
                    let alert = AlertController(title: "차단이 완료되었습니다", message: "", preferredStyle: .alert)
                    alert.setTitleImage(UIImage(named: "alertComplete"))
                    let action = UIAlertAction(title: "확인", style: .default) { (action) in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    action.setValue(UIColor.appColor(.green2), forKey: "titleTextColor")
                    alert.addAction(action)
                    self?.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    /*
     활동 내역에서 모두 보기 눌렀을 경우
     */
    
    @IBAction func pressedMoreBtn(_ sender: Any) {
        let btn: UIButton = sender as! UIButton
        
        switch btn.tag {
        case MyProfileMoreBtn.like.rawValue:
            break
            
        case MyProfileMoreBtn.scrap.rawValue:
            break
            
        case MyProfileMoreBtn.heart.rawValue:
            break
            
        default:
            break
        }
        
        print("클릭")
        performSegue(withIdentifier: "ArchiveVC", sender: nil)
        //        performSegue(withIdentifier: "ArchiveVC", sender: nil)
    }
    
    /*
     Menu 버튼을 눌렀을 경우
     */
    @IBAction func pressedMenuBtn(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        switch viewModel.isMyProfile() {
        
        // 내 프로필일때
        case true:
            // Create your actions - take a look at different style attributes
            
//            let nicknameChangeAction = UIAlertAction(title: "닉네임 수정하기", style: .default) { (action) in
//                // observe it in the buttons block, what button has been pressed
//                print("didPress report abuse")
//            }
            
//            let interestChangeAction = UIAlertAction(title: "관심사 수정하기", style: .default) { (action) in
//                print("didPress block")
//            }
            
//            actionSheet.addAction(nicknameChangeAction)
//            actionSheet.addAction(interestChangeAction)
//            actionSheet.addAction(logoutAction)
            
            break
            
        // 상대방 프로필일때
        case false:
            
            // 신고하기 버튼을 누를 경우 프로필로 이동
            let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { (action) in
                print("didPress block")
                
                guard let profileImage: UIImage = self.profile.image,
                      let nickname: String = self.nicknameLabel.text else {
                    return
                }
                
                let profileUID: String = self.viewModel.profileUID.value
                
                ReportManager.gotoReportScreen(reportType: .user,
                                               vc: self,
                                               profileImage: profileImage,
                                               nickname: nickname,
                                               text: "",
                                               createAt: "",
                                               userUid: profileUID,
                                               contentUid: "",
                                               targetBoard: .profile)
            }
            
            // 신고하기 버튼을 누를 경우 프로필로 이동
            let blockAction = UIAlertAction(title: "차단하기", style: .destructive) { (action) in
                print("차단하기 버튼을 클릭하셨습니다")
                
                let profileUID: String = self.viewModel.profileUID.value
                
                self.blockUser(targetUserUID: profileUID)
            }
            
            
            actionSheet.addAction(reportAction)
            actionSheet.addAction(blockAction)
            
            break
            
        }
        
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel) { (action) in
            print("didPress cancel")
        }
        actionSheet.addAction(cancelAction)
        
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /*
     Dpti 버튼을 눌렀을 경우
     */
    @IBAction func pressedDptiBtn(_ sender: Any) {
        if viewModel.myDptiTypeIsDefault() == true && viewModel.isMyProfile() == true {
            print("DPTI를 진행하지 않았으므로 DPTI 팝업을 띄웁니다")
            DptiPopupManager.dptiPopup(popupScreen: .profile, vc: self)
        } else if viewModel.myDptiTypeIsDefault() == true && viewModel.isMyProfile() == false {
            performSegue(withIdentifier: "MyDptiVC", sender: sender)
            print("DPTI는 진행하지 않았지만, 내 프로필이 아니므로 결과를 봅니다.")
        } else {
            performSegue(withIdentifier: "MyDptiVC", sender: sender)
            print("DPTI도 진행했고, 내 프로필이므로 DPTI 결과를 봅니다.")
        }
    }
    
    /*
     쪽지 보내기 버튼을 클릭했을 경우
     */
    @IBAction func pressedMessageBtn(_ sender: Any) {
        performSegue(withIdentifier: "MessageVC", sender: sender)
    }
    
    /*
     활동 내역 오른쪽 인포메이션 버튼 클릭했을 경우
     */
    var isSettingMedalInformationView: Bool = false
    @IBAction func pressedMedalInfoBtn(_ sender: Any) {
        performSegue(withIdentifier: "MedalInformationVC", sender: sender)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        switch segue.identifier {
        case "MyDptiVC":
            let destinationVC = destination as! ProfileDptiResultVC
            destinationVC.viewModel.typeRelay.accept(self.viewModel.getUserType())
            break
            
        case "ArchiveVC":
            break
            
        case "MessageVC":
            let destinationVC = destination as! MessageVC
            // 메세지 보내는 창에 유저 UID를 전송
            destinationVC.viewModel.yourUserUID.accept(self.viewModel.profileUID.value)
            destinationVC.viewModel.yourUserType.accept(self.viewModel.getUserType())
            
            break
            
        default:
            break
        }
    }
}


//MARK: - 차단하기

extension MyProfileVC {
    func blockUser(targetUserUID: String) {
        let alert = AlertController(title: "정말 차단하시겠어요?", message: "해당 사용자와 관련된 모든 컨텐츠를 볼 수 없습니다", preferredStyle: .alert)
        alert.setTitleImage(UIImage(named: "alertError"))
        let action = UIAlertAction(title: "확인", style: .destructive) { (action) in
            print("신고를 진행합니다.")
            self.viewModel.blockUser(targetUserUID: targetUserUID)
        }
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        alert.addAction(action)
        alert.addAction(cancle)
        present(alert, animated: true, completion: nil)
    }
}
