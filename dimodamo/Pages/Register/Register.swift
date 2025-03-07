//
//  Register.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/25.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

// 가입 프로세스에 포함되는 정보
// 추가된다면 DPTI 추가 될듯
struct Register {
    var createdAt: String = ""
    var dpti: String = "DD"
    
    
    var id: String = ""
    
    
    var getCommentHeartCounnt: Int = 0
    var getManitoGoodCount: Int = 0
    var getProfileScore: Int = 0
    var getScrapCount: Int = 0
    
    var Interest: [Interest] = []
    var marketing: Bool = false
    var nickName: String = ""
    
    var report: Int = 0
    var reportList: [String : Bool] = [:]
    
    var school: String = ""
    var schoolCertState: CertificationState = .none
    var schoolId: String = ""
    
    var scrapPosts: [String] = []
    
    var heartComments: [String] = []
    var heartCommentList: [String : Bool] = [:]
    
    func getDict() -> [String:Any] {
        
        let dict: [String:Any] = [
            "created_at" : self.createdAt,
            "dpti" : "DD",
            "id": self.id,
            "get_comment_heart_count" : getCommentHeartCounnt,
            "get_manito_good_count" : getManitoGoodCount,
            "get_profile_score" : getProfileScore,
            "get_scrap_count": getScrapCount,
            "interest": [
                self.Interest[0].description,
                self.Interest[1].description,
                self.Interest[2].description,
            ],
            "marketing": self.marketing == true ? "true" : "false",
            "nickName": self.nickName,
            "report": self.report,
            "report_list": self.reportList,
            "school" : self.school,
            "schoolId" : self.schoolId,
            "schoolCert" : self.schoolCertState.description,
            "rejectionReason" : "",
            "scrapPosts": self.scrapPosts,
            "heartComments": self.heartComments,
            "heartCommentList": self.heartCommentList
        ]
        
        return dict
    }
}

enum MailCheck {
    case none
    case possible
    case impossible
}

enum PWCheck {
    case nothing                // 아무것도 입력하지 않았을 경우
    case onlyFirstTextfield     // 첫 번째 텍스트 필드만 입력 한 경우
    case possible               // 패스워드 사용이 가능한 경우
}

enum NicknameCheck {
    case nothing
    case possible
    case impossible
}

// 성별
enum Gender {
    case female
    case male
    case none
    
    var description: String {
        switch self {
        case .female:
            return "F"
        case .male:
            return "M"
        case .none:
            return ""
        }
    }
}

// 학교 인증 진행 정도
enum CertificationState {
    case none       // 제출하지 않음
    case submit     // 제출
    case rejection  // 거절
    case approval   // 승인
    
    var description: String {
        switch self {
        case .none:
            return "none"
        case .submit:
            return "submit"
        case .rejection:
            return "rejection"
        case .approval:
            return "approval"
        }
    }
}

// 관심사 3종 목록
enum Interest: Int {
    case uxui           // UXUI
    case edit           // 편집디자인
    case architecture   // 건축디자인
    case branding       // 브랜딩
    case font           // 폰트
    case exhibit        // 전시무대
    case ad             // 광고
    case crafts         // 공예
    case animation      // 애니메이션
    case broadcasting   // 방송채널
    case industrial     // 산업
    case motion         // 모션
    case product        // 제품
    case media          // 미디어
    case interior       // 실내
    case space          // 무대
    case director      // 디렉터
    case art            // 아트
    
    
    var description: String {
        switch self {
        case .ad:
            return "ad"
        case .uxui:
            return "uxui"
        case .edit:
            return "edit"
        case .architecture:
            return "architecture"
        case .branding:
            return "branding"
        case .font:
            return "font"
        case .exhibit:
            return "exhibit"
        case .crafts:
            return "crafts"
        case .animation:
            return "animation"
        case .broadcasting:
            return "broadcasting"
        case .industrial:
            return "industrial"
        case .motion:
            return "motion"
            
        case .product:
            return "product"
        case .media:
            return "media"
        case .interior:
            return "interior"
            
        case .space:
            return "space"
        case .director:
            return "director"
        case .art:
            return "art"
        
        }
    }
    
    static func getWordFromString(from interest: String) -> String {
        switch interest {
        case "ad":
            return "광고"
        case "uxui":
            return "UXUI"
        case "edit":
            return "편집"
        case "architecture":
            return "건축"
        case "branding":
            return "브랜딩"
        case "font":
            return "폰트"
        case "exhibit":
            return "전시"
        case "crafts":
            return "공예"
        case "animation":
            return "애니"
        case "broadcasting":
            return "방송"
        case "industrial":
            return "산업"
        case "motion":
            return "모션"
        case "product":
            return "제품"
        case "media":
            return "미디어"
        case "interior":
            return "실내"
        case "space":
            return "무대"
        case "director":
            return "디렉터"
        case "art":
            return "아트"

        default:
            return ""
        }
    }
}
