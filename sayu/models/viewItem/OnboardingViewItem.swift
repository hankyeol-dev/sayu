//
//  OnboardingViewItem.swift
//  sayu
//
//  Created by 강한결 on 9/27/24.
//

import Foundation

struct OnboardingViewItem: Identifiable, Hashable {
   let id: UUID = .init()
   let image: ImageResource
   let title: String
   let contents: String
}
