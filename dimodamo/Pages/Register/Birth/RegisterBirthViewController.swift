//
//  RegisterBirthViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/22.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RegisterBirthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    
    var viewModel : RegisterViewModel?
    var disposeBag = DisposeBag()
    
    
    private var datePicker: UIDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // 화면이 로드될 경우에 키보드 올라오도록
        yearTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerBirthDesign()
    
        yearTextField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                if (self?.yearTextField.text!.count)! >= 4 {
                    self?.viewModel?.birth.accept((self?.yearTextField.text!)!)
                    self?.monthTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        monthTextField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                if (self?.monthTextField.text!.count)! >= 2 {
                    self?.viewModel?.month.accept((self?.monthTextField.text!)!)
                    self?.dayTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        dayTextField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] in
                if (self?.dayTextField.text!.count)! >= 2 {
                    self?.viewModel?.day.accept((self?.dayTextField.text!)!)
                    self?.dayTextField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel!.birth.map { $0.count >= 4 },
            viewModel!.month.map { $0.count >= 2 },
            viewModel!.day.map { $0.count >= 2 }
            )
        .observeOn(MainScheduler.instance)
        .subscribe { [weak self] birth, month, day in
            if birth && month && day {
                UIView.animate(withDuration: 0.5) {
                    self?.checkIcon.alpha = 1
                    self?.progress.setProgress(0.42, animated: true)
                    AppStyleGuide.systemBtnRadius16(btn: (self?.nextBtn)!, isActive: true)
                    print(String((self?.viewModel!.birthMonthDay)!))
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self?.checkIcon.alpha = 0
                    self?.progress.setProgress(0.28, animated: true)
                    AppStyleGuide.systemBtnRadius16(btn: (self?.nextBtn)!, isActive: false)
                }
            }
        }
        .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveUpTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveDownTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InputGender" {
            let destinationVC = segue.destination as? RegisterGenderViewController
            destinationVC?.viewModel = self.viewModel
        }
    }
    
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

    @IBAction func pressedNextBtn(_ sender: Any) {
        performSegue(withIdentifier: "InputGender", sender: sender)
    }
    @IBAction func pressedCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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


extension RegisterBirthViewController {
    
    func registerBirthDesign() {
        AppStyleGuide.systemBtnRadius16(btn: nextBtn, isActive: false)
        checkIcon.alpha = 0
    }
}
