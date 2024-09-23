//
//  SayuCardListView.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

import MijickNavigationView

struct SayuCardListView: NavigatableView {
   let dateString: String
   let sayuCardItemList: [SayuCardItem]
   
   var body: some View {
      VStack(alignment: .leading) {
         if let date = dateString.formattedForView()?.formattedForView() {
            HStack(alignment: .center, spacing: 8.0) {
               Image(.folder)
                  .resizable()
                  .frame(width: 16.0, height: 14.0)
               Text(date + "의 사유")
                  .byCustomFont(.gmMedium, size: 15.0)
            }
         }
         
         Spacer.height(20.0)
         
         ForEach(sayuCardItemList, id: \.id) { cardItem in
            SayuCardView(sayuCardItem: cardItem)
            Spacer.height(16.0)
         }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.horizontal, 16.0)
      .padding(.bottom, 24.0)
   }
}

struct SayuCardView: NavigatableView {
   
   let sayuCardItem: SayuCardItem
   
   var body: some View {
      VStack(alignment: .center) {
         Text(sayuCardItem.subject)
            .byCustomFont(.gmMedium, size: 15.0)
            .frame(height: 24.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .foregroundStyle(.baseBlack)
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .background(.baseGreenSm)
         Spacer.height(4.0)
         
         VStack {
            if !sayuCardItem.content.isEmpty {
               Text(sayuCardItem.content)
                  .byCustomFont(.gmMedium, size: 14.0)
                  .foregroundStyle(.grayXl)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .lineLimit(2)
                  .lineSpacing(4.0)
               Spacer.height(16.0)
            }
           
            HStack(alignment: .center) {
               if sayuCardItem.subCount != 0 {
                  HStack(alignment: .center, spacing: 6.0) {
                     Image(.docs)
                        .resizable()
                        .frame(width: 8.0, height: 10.0)
                     Text("\(sayuCardItem.subCount)개의 세부 사유")
                        .byCustomFont(.gmlight, size: 13.0)
                  }
                  
                  Text(" · ")
                     .byCustomFont(.gmlight, size: 13.0)
               }
               
               HStack(alignment: .center, spacing: 4.0) {
                  Image(.stopwatch)
                     .resizable()
                     .frame(width: 12, height: 12)
                  Text("\(sayuCardItem.timeTake)")
                     .byCustomFont(.gmlight, size: 13.0)
               }
               
               Text(" · ")
                  .byCustomFont(.gmlight, size: 13.0)
               
               Text("\(sayuCardItem.thinkType)")
                  .byCustomFont(.gmlight, size: 13.0)
               
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !sayuCardItem.smartList.isEmpty {
               Spacer.height(16.0)
               HStack(alignment: .center) {
                  ForEach(sayuCardItem.smartList, id: \.self) { list in
                     Text(list)
                        .byCustomFont(.gmlight, size: 12.0)
                        .padding(.horizontal, 8.0)
                        .padding(.vertical, 6.0)
                        .background(Capsule()
                           .stroke(lineWidth: 1.0)
                           .foregroundStyle(.grayLg))
                           .background(.grayXs)
                  }
               }
               .frame(maxWidth: .infinity, alignment: .topLeading)
            }
         }
         .padding(.horizontal, 12.0)
         .padding(.top, 8.0)
         .padding(.bottom, 16.0)
      }
      .frame(maxWidth: .infinity)
      .overlay {
         RoundedRectangle(cornerRadius: 8.0)
            .stroke(lineWidth: 1.5)
            .foregroundStyle(.baseBlack)
      }
      .clipShape(.rect(cornerRadius: 8.0))
   }
}
