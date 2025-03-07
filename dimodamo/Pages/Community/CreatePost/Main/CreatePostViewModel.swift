//
//  CreatePostViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/10/25.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

import SwiftLinkPreview

class CreatePostViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    // 제목
    let titleRelay = BehaviorRelay<String>(value: "")
    var titleLimit: String { return "\(titleRelay.value.count)/20" }
    var titleIsValid: Bool { return titleRelay.value.count > 0 }
    
    // 태그
    let tagsRelay = BehaviorRelay<String>(value: "")
    var tags: [String] = []
    var tagsLimit: String {
        // # 태그가 있는 단어들을 찾아서 태그 때고  다 소문자로 해주기
        let sliceArray = tagsRelay.value.getArrayAfterRegex(regex:"#[^ ]+").map { (slice) in
            slice.replacingOccurrences(of: "#", with: "").lowercased()
        }
        tags = sliceArray
        print(tags)
        return "\(sliceArray.count)/2"
    }
    var tagsLimitCount: Int {
        let sliceArray = tagsRelay.value.getArrayAfterRegex(regex:"#[^ ]+").map { (slice) in
            slice.replacingOccurrences(of: "#", with: "").lowercased()
        }
        
        return sliceArray.count
    }
    
    // 내용
    let descriptionRelay = BehaviorRelay<String>(value: "")
    var descriptionLimit: String {
        return "\(descriptionRelay.value.count)/5000"
    }
    var descriptionIsValid: Bool { return descriptionRelay.value.count > 0 }
    let descriptionPlaceholderText = """
    디모다모는 사용자들의 자유로운 사용을 지향합니다. 깨끗한 커뮤니티를 위해 노력해주시기 바랍니다.

    욕설, 혐오표현, 성적 비하, 차별발언, 특정인 및 지역 비하, 도배, 여론조작, 권리침해, 정치홍보, 음란성 게시물 등은 금지되어 있으며,  위의 나열된 행동 이외에도 커뮤니티 이용규칙에 어긋나는 게시물은 삭제되며, 글쓰기 제한, 서비스 이용정지 등의 제재가 가해질 수 있습니다. 자세한 내용은 설정 내의 커뮤니티 이용규칙을 확인하시기 바랍니다.
    """
    
    
    /*
     
     업로드 이미지
     */
    let uploadImagesRelay = BehaviorRelay<[UIImage]>(value: []) // 유저가 사진을 찍거나, 앨범에서 선택할 때마다 이쪽으로 넘길 예정
    var uploadImageUrlArr: [String] = [] // 업로드 하기 전에 파이어베이스 링크를 넣음
    let uploadImageLoading = BehaviorRelay<Bool>(value: false)
    
    /*
     업로드 링크
     */
    var uploadLink: String?
    var uploadLinks: [String] = [] // 링크만 가지고 있음 (최종적으로 글 작성시, 어레이가 필요하므로)
    
    let uploadLinkDataRelay = BehaviorRelay<PreviewResponse?>(value: nil)
    let uploadLinksDataRelay = BehaviorRelay<[PreviewResponse]>(value: []) // 링크에 있는 데이터를 해체해 가지고 있음
    let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    /*
     최종 글 작성 로딩
     */
    let sendPostLoading = BehaviorRelay<Bool?>(value: nil)
    
    init() {
        
    }
    
    func upload(){
        self.sendPostLoading.accept(true)
        let queue = DispatchQueue(label: "UPLOAD")
        
        let unixTimestamp = NSDate().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let strDate = dateFormatter.string(from: date)
        
        // 유저 디폹트에서 닉네임을 불러옴
        let userDefaults = UserDefaults.standard
        let userNickname: String = userDefaults.string(forKey: "nickname") ?? "익명"
        let userDpti: String = userDefaults.string(forKey: "dpti") ?? "DD"
        
        // DocumentID를 미리 불러오기 위해
        
        let document = db.collection("hongik/article/posts").document()
        let id: String = document.documentID
        var board: Board?
        
        queue.async { [weak self] in
            // 이미지 업로드 프로세스
            self?.uploadImage(documentID: document.documentID, completion:{ (isSucceded) in
                
                // 이미지 업로드 할 때까지 기다림
                if isSucceded {
                    print("업로드 성공")
                    
                    
                    // 이미지 업로드에 성공 했다면 글 작성 시작
                    queue.async { [weak self] in
                        print("\(self!.uploadLinks)")
            
                        board = Board(boardId: id,
                                      boardTitle: self!.titleRelay.value,
                                      bundleId: unixTimestamp,
                                      category: "magazine",
                                      commentCount: 0,
                                      createdAt: "\(strDate)",
                                      description: "\(self!.descriptionRelay.value)",
                                      images: self!.uploadImageUrlArr,
                                      links: self!.uploadLinks,
                                      nickname: userNickname,
                                      scrapCount: 0,
                                      tags: self!.tags,
                                      userDpti: userDpti,
                                      userId: Auth.auth().currentUser?.uid,
                                      videos: [])
                        
                        document.setData(board!.dictionary) { err in
                            if let err = err {
                                print("게시글을 작성하는데 오류가 발생했습니다. \(err.localizedDescription)")
                            } else {
                                print("정상적으로 글이 작성되었습니다. \(id)")
                                self?.sendPostLoading.accept(false)
                            }
                        }
                    }
                    
                    // 이미지 업로드에 실패했다면, 글 작성 역시 실패하도록
                } else {
                    print("업로드 실패")
                }
            })
        }
    }
    
    func sendPost() {
        
    }
    
    /*
     Delete Logic
     */
    func deleteImage(tagIndex: Int) {
        var imageArr: [UIImage] = self.uploadImagesRelay.value
        imageArr.remove(at: tagIndex)
        
        self.uploadImagesRelay.accept(imageArr)
        
        print("Images Delete Complete!")
    }
    
    func deleteLink(tagIndex: Int) {
        var linkStringArr: [String] = uploadLinks
        linkStringArr.remove(at: tagIndex)
        self.uploadLinks = linkStringArr
        
        var linkDataArr = uploadLinksDataRelay.value
        linkDataArr.remove(at: tagIndex)
        self.uploadLinksDataRelay.accept(linkDataArr)
        
        print("Links Delete Complete!")
    }
    
    
    /*
     Link Setting
     */
    func linkViewSetting(uploadLink: String, uploadLinkData: PreviewResponse) {
        
        // LinkPopupVC에서 전달 받은 데이터를 먼저 넣은 뒤에
        self.uploadLinkDataRelay.accept(uploadLinkData) // 이미지 그리기 위한 용도 구조체
        self.uploadLink = uploadLink // 게시글 업로드용
        
        var linksData: [PreviewResponse] = [] // 이전 링크 데이터
        var linksString: [String] = [] // urlString만 담기 위해
        
        // 유저에게 입력받은 새로운 링크 데이터
        guard let newLinkData: PreviewResponse = uploadLinkDataRelay.value,
              let newLinkString: String = self.uploadLink else {
            return
        }
        
        print("\(newLinkString)")
        // 기존 데이터를 먼저 가져 온 뒤에
        linksData = self.uploadLinksDataRelay.value
        linksString = self.uploadLinks
        // 합침
        linksData.append(newLinkData)
        linksString.append(newLinkString)
        
        self.uploadLinksDataRelay.accept(linksData)
        self.uploadLinks = linksString
        
        print("uploadLinks = \(linksString)")
    }
    
    // TODO : 도큐먼트 아이디를 받아서 for문 돌려서
    func uploadImage(documentID: String, completion: @escaping (Bool) -> Void) {
        if uploadImagesRelay.value.count == 0 {
            print("이미지가 없으므로 바로 넘어갑니다.")
            return completion(true)
        }
        
        let queue = DispatchQueue(label: "UPLOADIMAGE")
        var urlStringArr: [String] = []
        
        
        for (index, image) in uploadImagesRelay.value.enumerated() {
            guard let uploadData = image.resize(withWidth: 1280)?.jpeg(.medium) else {
                return completion(false)
            }
            let storageRef = storage.child("hongik/information/posts/\(documentID)_\(index).png")
            var urlString: String = ""
            
            queue.async { [self] in
                storageRef.putData(uploadData, metadata: nil) { _, error in
                    guard error == nil else {
                        print("Failed to upload")
                        return completion(false)
                    }
                    
                    queue.async { [self] in
                        storageRef.downloadURL(completion: { url, error in
                            guard let url = url, error == nil else {
                                return completion(false)
                            }
                            
                            urlString = url.absoluteString
                            print("DownloadURL : \(urlString)")
                            urlStringArr.append(urlString)
                            //                            UserDefaults.standard.set(urlString, forKey: "url")
                            
                            queue.async { [self] in
                                print("여기에 들어온 시간")
                                if urlStringArr.count == (uploadImagesRelay.value.count) {
                                    self.uploadImageUrlArr = urlStringArr
                                    return completion(true)
                                }
                            }
                            
                        })
                    }
                }
            }
            
        }
        
        
    }
}



// MARK: - 정규식 익스텐션
// https://eunjin3786.tistory.com/12

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
