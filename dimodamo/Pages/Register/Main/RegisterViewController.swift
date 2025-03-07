//
//  RegisterViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/21.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    // MARK: - All Screen IBOutlet
    // 넥스트 버튼 디자인용 참조
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    // MARK: - School Screen IBOutlet
    @IBOutlet weak var nextCertifySchoolBtn: UIButton!
    
    
    // MARK: - View
    
    var disposeBag = DisposeBag() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDesign()
        
        closeBtn?.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext : { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
                
        NotificationCenter.default.addObserver(self, selector: #selector(moveUpTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveDownTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    
    // 키보드 업, 다운 관련
    @objc func moveUpTextView(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0, animations: {
                            self.nextBtn?.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
            })
        }
    }
    
    @objc func moveDownTextView() {
        self.nextBtn?.transform = .identity
    }

    
    @IBAction func pressedNicknameNextBtn(_ sender: Any) {
        performSegue(withIdentifier: "InputSchool", sender: sender)
    }
    
}

// MARK: -View Design


extension RegisterViewController {
    
    func viewDesign() {
        designNextBtn()
        navigationBarDesign()

        designSchoolBtn()
    }
    
    func designNextBtn() {
        nextBtn?.backgroundColor = UIColor.appColor(.systemUnactive)
        nextBtn?.layer.cornerRadius = 16
    }
    
    func navigationBarDesign() {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
    }
    
    func designSchoolBtn() {
        nextCertifySchoolBtn?.layer.cornerRadius = 16
    }
}
