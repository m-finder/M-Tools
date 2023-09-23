//
//  TexterView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct TexterView: View {
    @AppStorage("showTexter") var showTexter: Bool = false
    @AppStorage("texter") var texter: String = String(localized: "Drink more water.")
    @AppStorage("colorIndex") var colorIndex: Int = 0
    @ObservedObject var colorModel: ColorModel = ColorModel()
    
    var body: some View {
        
        if showTexter {
            HStack(spacing: 4) {
                VStack(alignment: .trailing, spacing: -2) {
                    if colorIndex == 0 {
                        Text(texter)
                    } else {
                        Text(texter).foregroundStyle(LinearGradient(
                                colors: colorModel.getColor(index: colorIndex),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                        ))
                    }
                }
            }.padding(2)
        }
    }
}

#Preview {
    TexterView()
}
