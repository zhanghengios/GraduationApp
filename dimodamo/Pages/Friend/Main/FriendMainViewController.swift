//
//  FriendMainViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/21.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import KakaoSDKAuth

class FriendMainViewController: UIViewController {
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("마니또 연결이 되었니?")
        
        AuthApi.shared.rx.loginWithKakaoAccount()
            .subscribe(onNext:{ (oauthToken) in
                print("loginWithKakaoAccount() success.")

                //do something
                _ = oauthToken
            }, onError: {error in
                print(error)
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
