//
//  CpuView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct CpuView: View {
    @AppStorage("showCpu") var showCpu: Bool = false
    @StateObject var cpuInfo = CpuInfo()
    @StateObject var width = MonitorFrameWidth()
    
    var body: some View {
        HStack(spacing: 4) {
            if showCpu {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "cpu") .resizable().frame(width: 12, height: 12)
                    
                    HStack(spacing: 1) {
                        Text(String(format: "%.1f", cpuInfo.getUsageValue())).frame(width: 30)
                        Text("%").font(.system(size: 8))
                    }
                }.font(.caption).frame(width: width.value).padding(2)
            }
        }

    }
}

#Preview {
    CpuView()
}
