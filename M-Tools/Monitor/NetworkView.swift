//
//  NetworkView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import SwiftUI

struct NetworkView: View {
    
    @AppStorage("showNetwork") var showNetwork: Bool = false
    @StateObject var networkInfo = NetworkInfo()
    @StateObject var width = MonitorFrameWidth()
    
    var body: some View {
        if showNetwork {
            HStack(alignment: .center, spacing: 1) {
                Image(systemName: "arrow.up.arrow.down").resizable().frame(width: 10, height: 8)
                
                VStack(alignment: .trailing, spacing: -1) {
                    HStack(spacing: 0){
                        Text(String(format: "%.1f", networkInfo.getUploadSpeed().value))
                            .frame(width: 25)
                            .font(.system(size: 8))
                        Text(String(format: "%@", networkInfo.getUploadSpeed().unit))
                            .frame(width: 20)
                            .font(.system(size: 8))
                    }
                    
                    HStack(spacing: 0){
                        Text(String(format: "%.1f", networkInfo.getDownloadSeed().value))
                            .frame(width: 25)
                            .font(.system(size: 8))
                        Text(String(format: "%@", networkInfo.getDownloadSeed().unit))
                            .frame(width: 20)
                            .font(.system(size: 8))
                    }
                }
            }.frame(width: (width.value + 5)).padding(4)
        }
    }
}

#Preview {
    NetworkView()
}
