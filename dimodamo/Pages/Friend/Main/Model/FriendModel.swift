//
//  FriendModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/25.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

struct Message {
    var uid: String = "" // messages의 uid
    var message: String = "" // 메세지 내용
    var photo: String = "" // 이미지 URL
    var timestamp: Int = 0
    var user_uid: String = "" // user_uid를 통해서 닉네임과 dpti 가져오기
    var is_read: Bool = false // 읽음 표시
}

struct ChatUsers: Codable {
    
}

// 유저별 채팅방 리스트
struct userChatList {
    var last_message: String = ""
    var chat_room_uid: String = ""
    var target_user_uid: String = ""
    var timestamp: Int = 0
    var unread_message_count: Int = 0
}

// target_user_uid에서 긁어옴
struct chatUserData {
    var nickname: String = ""
    var dpti: String = ""
}
