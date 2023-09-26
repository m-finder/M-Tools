//
//  TexterPopoverView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct TexterPopoverView: View {
    @AppStorage("texter") var texter: String = String(localized: "Drink more water.")
    @AppStorage("colorIndex") var colorIndex: Int = 0
    @ObservedObject var colorModel : ColorModel = ColorModel()
    
    var body: some View {
        VStack(alignment: .center) {
            
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)

            // 标题
            if colorIndex == 0{
                Text("M-Texter").font(.system(size: 24, weight: .semibold, design: .rounded))
            }else{
                Text("M-Texter")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(LinearGradient(
                    colors: colorModel.getColor(index: colorIndex),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            }


            // 菜单栏文本
            VStack(alignment: .leading) {

                Divider()

                LabelledDivider(label: String(localized: "MenuBar Text"))
                TextField(String(localized: "Input something"), text: $texter)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: texter) { newValue in
                        if newValue.count > 15 {
                            texter = String(newValue.prefix(15))
                        }
                    }
            }
            
            // 多彩文字
            VStack{
                LabelledDivider(label: String(localized: "Colorful Text"))

                HStack(alignment: .center, spacing: 10){
                    
                    ForEach(colorModel.getColors().indices, id: \.self) { index in
                        Button {
                            colorIndex = index
                        } label: {

                            Image(systemName: colorIndex == index ? "checkmark.square.fill" : "square.fill")
                                .foregroundStyle(LinearGradient(
                                    colors: colorModel.getColor(index: index),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))

                        }.buttonStyle(.plain)

                    }
                }
             
            }
        }
        .padding()
    }
}

#Preview {
    TexterPopoverView()
}
