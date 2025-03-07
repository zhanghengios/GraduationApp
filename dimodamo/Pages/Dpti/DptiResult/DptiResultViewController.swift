//
//  DptiResultViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/11.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import Lottie

class DptiResultViewController: UIViewController {

    // height는 빌드할 때 사라지도록 해놓음
    @IBOutlet weak var resultCardView: UIView! {
        didSet {
            resultCardView.layer.cornerRadius = 24
            let aspectRatioHeight: CGFloat = (348 / 414) * UIScreen.main.bounds.width
            resultCardView.heightAnchor.constraint(equalToConstant: aspectRatioHeight).isActive = true
            resultCardView.appShadow(.s12)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeIcon: UIImageView! {
        didSet {
            typeIcon.appShadow(.s12)
        }
    }
    @IBOutlet weak var typeDesc: UITextView!
    @IBOutlet weak var typeChar: UIImageView!
    @IBOutlet weak var patternBG: UIImageView!
    @IBOutlet weak var positionIcon: UIImageView!
    @IBOutlet weak var positionDesc: UILabel!
    @IBOutlet weak var circleNumber: UILabel!
    @IBOutlet var designs : Array<UILabel>!
    @IBOutlet var designsDesc : Array<UILabel>!
    @IBOutlet weak var toolImg: UIImageView!
    @IBOutlet weak var toolName: UILabel!
    @IBOutlet weak var toolDesc: UITextView!
    @IBOutlet weak var todo: UITextView!
    @IBOutlet var circleNumbers : Array<UILabel>?
    
    let viewModel = DptiResultViewModel()
    var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // UILabel Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ($0.title, self?.typeTitle),
                ($0.design[0], self?.designs[0]),
                ($0.design[1], self?.designs[1]),
                ($0.toolName, self?.toolName),
                ($0.position, self?.positionDesc),
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { text, label in
            label?.text = text
        })
        .disposed(by: disposeBag)
        
        // TypeDesc Binding
        viewModel.typeDesc
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(typeDesc.rx.text)
            .disposed(by: disposeBag)
    
        
        viewModel.designsDesc
            .map{ "\($0[0])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[0].rx.text)
            .disposed(by: disposeBag)

        
        viewModel.designsDesc
            .map{ "\($0[1])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[1].rx.text)
            .disposed(by: disposeBag)
    
        
        // UITextView Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ($0.toolDesc, self?.toolDesc),
                ($0.todo, self?.todo)
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { text, textView in
            textView?.text = text
        })
        .disposed(by: disposeBag)
        
        // UIImage Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ("BC_Type_\($0.shape)", self?.typeIcon),
                ("BC_BG_P_\($0.shape)", self?.patternBG),
                ("Icon_\($0.type)", self?.positionIcon),
                ($0.toolImg, self?.toolImg)
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { imageName, uiImage in
            uiImage?.image = UIImage(named : imageName)
        })
        .disposed(by: disposeBag)
        
            
       
        viewModel.genderObservable
            .observeOn(MainScheduler.instance)
            .subscribe (onNext : { value in
                print(value)
                self.lottieChar(type: self.viewModel.type)
            })
            .disposed(by: disposeBag)

        
        
                
        resultCardViewInit()
        circleNumberSetting()
        
        let attrString = NSAttributedString(
            string: typeTitle.text!,
            attributes: [
                NSAttributedString.Key.strokeColor: UIColor.white,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeWidth: -2.0,
            ]
        )
        typeTitle.attributedText = attrString
    }
    
    // 완료버튼을 눌렀을 경우 -> 메인화면으로
    @IBAction func pressedClearBtn(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        // 원본
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC")
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true, completion: nil)
    }
    
    func resultCardViewInit() {
        
        // resultCard Background Change
        viewModel.colorHex
            .map { $0 }
            .asDriver(onErrorJustReturn: UIColor.black)
            .drive(resultCardView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // ColorSetting
        positionDesc.textColor = UIColor.appColor(.system)
        toolName.textColor = UIColor.appColor(.system)
        designs[0].textColor = UIColor.appColor(.system)
        designs[1].textColor = UIColor.appColor(.system)
    }
    
    func circleNumberSetting() {
        for circleNumber in circleNumbers! {
            circleNumber.layer.cornerRadius = 16
            circleNumber.backgroundColor = UIColor.appColor(.system)
            circleNumber.layer.masksToBounds = true
        }
    }
    
    func lottieChar(type: String) {
        let animationView = Lottie.AnimationView.init(name: "\(type)")
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        resultCardView.addSubview(animationView)
        animationView.topAnchor.constraint(equalTo: resultCardView.topAnchor, constant: 0).isActive = true
        animationView.leftAnchor.constraint(equalTo: resultCardView.leftAnchor, constant: 0).isActive = true
        animationView.rightAnchor.constraint(equalTo: resultCardView.rightAnchor, constant: 0).isActive = true
        animationView.bottomAnchor.constraint(equalTo: resultCardView.bottomAnchor, constant: 0).isActive = true
        
        animationView.layer.cornerRadius = 24
        animationView.play()
        animationView.loopMode = .loop
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

