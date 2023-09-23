//
//  BatteryView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct BatteryView: View {
    
    @AppStorage("showBattery") var showBattery: Bool = false
    @StateObject var batteryInfo = BatteryInfo()
    @StateObject var width = MonitorFrameWidth()
    
    var body: some View {
        if showBattery {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: batteryInfo.getImage()).resizable().frame(width: 14, height: 8)
                
                HStack(spacing: 1) {
                    Text(String(format: "%.1f", batteryInfo.getUsageValue())).frame(width: 28)
                    Text("%").font(.system(size: 8))
                }
            }.font(.caption).frame(width: width.value).padding(2)
        }
    }
}

#Preview {
    BatteryView()
}
