//
//  DiskView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct DiskView: View {
    
    @AppStorage("showDisk") var showDisk: Bool = false
    @StateObject var diskInfo = DiskInfo()
    @StateObject var width = MonitorFrameWidth()
    
    var body: some View {
        if showDisk {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "internaldrive").resizable().frame(width: 14, height: 8)
                HStack(spacing: 1) {
                    Text(String(format: "%.1f", diskInfo.getUsageValue())).frame(width: 28)
                    Text("%").font(.system(size: 8))
                }
            }.font(.caption).frame(width: width.value).padding(2)
        }
    }
}

#Preview {
    DiskView()
}
