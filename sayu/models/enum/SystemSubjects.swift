//
//  SystemSubjects.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

@frozen
enum SystemSubjects: CaseIterable {
   case forMe
   case forMeHatePeople
   case forMeFavoritePeople
   case movie
   case book
   case weather
   
   var byKoreanSubject: String {
      switch self {
      case .forMe:
         "나에 대해서"
      case .forMeHatePeople:
         "그 사람은 왜 미울까?"
      case .forMeFavoritePeople:
         "그 사람이 왜 좋을까?"
      case .movie:
         "그 영화 보기 전"
      case .book:
         "어 나도 그 책 읽어봤어"
      case .weather:
         "오늘의 날씨"
      }
   }
   
   var getKoreanSubTitles: [String] {
      switch self {
      case .forMe:
         [
            "내가 정말 좋아하는 것은?",
            "내가 정말 싫어하는 것은?",
            "내가 생각하기에 요즘의 나는 어떤 사람일까?",
            "앞으로 1년 뒤의 나는 어떤 모습이었으면 좋겠어?",
            "당장 내일, 내가 중요하게 해야하는 일은?",
            "당장 오늘, 나는 얼마나 좋은 사람이었어?"
         ]
      case .forMeHatePeople:
         [
            "그 사람이 싫어진 이유는 뭘까?",
            "그 사람을 좋아해보려고 한 나의 노력은?",
            "그 사람과의 관계가 회복될 수 있을까?"
         ]
      case .forMeFavoritePeople:
         [
            "그 사람이 좋아진 이유는 뭘까?",
            "그 사람에게 배우고 싶은 점이 있다면?",
            "그 사람과의 관계를 더 좋게 이어가기 위해서는?"
         ]
      case .movie:
         [
            "영화 제목은?",
            "영화의 전반적인 줄거리는?",
            "영화를 보기 전 내가 기대하는 부분은?",
            "영화를 보고 난 지금, 나의 감정은?",
            "영화에서 가장 좋았던 부분은?",
            "영화에서 가장 아쉬웠던 부분은?"
         ]
      case .book:
         [
            "책의 제목은?",
            "책의 전반적인 줄거리는?",
            "책에서 가장 좋았던 문장이 있을까?",
            "다른 사람에게 이 책을 추천한다면 이유가 뭘까?"
         ]
      case .weather:
         [
            "오늘의 날씨를 경험하고 난 기분은?",
            "나는 날씨에 영향을 많이 받는 사람일까?",
            "나는 왜 날씨에 영향을 받을까?",
            "나는 어떤 날씨를 좋아할까? 왜?",
            "나는 어떤 날시를 싫어할까? 왜?"
         ]
      }
   }
}
