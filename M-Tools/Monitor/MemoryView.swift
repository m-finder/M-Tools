//
//  MemoryView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct MemoryView: View {
    
    @AppStorage("showMemory") var showMemory: Bool = false
    @StateObject var memoryInfo = MemoryInfo()
    @StateObject var width = MonitorFrameWidth()
    
    var body: some View {
        HStack(spacing: 4) {
            if showMemory {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "memorychip") .resizable().frame(width: 12, height: 12)
                    
                    HStack(spacing: 1) {
                        Text(String(format: "%.1f", memoryInfo.getUsageValue())).frame(width: 30)
                        Text("%").font(.system(size: 8))
                    }
                }.font(.caption).frame(width: width.value).padding(2)
            }
        }
    }
}

#Preview {
    MemoryView()
}
