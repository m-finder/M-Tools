//
//  MenuBarRunnerView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import SwiftUI

struct MenuBarRunnerView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("currentImageId") private var currentImageId: String = "A1AF9595-F3FC-4A4F-A134-8F9CED4B761D"
   
    @StateObject var cpuInfo = CpuInfo()
    
    @AppStorage("runnerSpeed") private var runnerSpeed = 0.5
    @AppStorage("speedProportional") private var speedProportional = true

    @State var width: CGFloat
    @State var height: CGFloat
    
    var runner: RunnerEntity? {
        get {
            let rq = RunnerEntity.fetchRequest()
            rq.predicate = NSPredicate(format: "id == %@", currentImageId)
        
            guard let res = try? viewContext.fetch(rq) else {
                fatalError("数据出现了问题")
            }
            return res.first
        }
    }
    
    init(width:CGFloat, height: CGFloat ) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        
        let factor = Float((speedProportional ? 1.0001 - Double(cpuInfo.getUsageValue() / 100) : Double(cpuInfo.getUsageValue()  / 100)) / 5 * (1.1 - runnerSpeed))
        let minInterval: Float = 0.012

        VStack {
            RunnerView(
                entity: runner,
                factor: clamp(factor, lowerBound: minInterval, upperBound: .infinity)
            ).frame(width: width, height: height)
        }
        
    }
}

struct RunnerView: View {
    
    var entity: RunnerEntity?
    var factor: Float
    var autoReverse = true
    
    @State var direction = 1
    @State var imageIndex = 0
    
    var body: some View {
        
        let timer = Timer.publish(every: TimeInterval(factor), on: .main, in: .common).autoconnect()
        
        VStack {
            if entity != nil {
                Image(entity!.getImage(imageIndex), scale: 1, label: Text("RunnerView")).resizable()
            } else {
                Image("AppLogo").resizable()
            }
        }.onReceive(timer) { _ in
            guard let frame_num = entity?.frame_num else {
                return
            }
            
            if imageIndex == 0 {
                direction = 1
            }
            
            if imageIndex >= frame_num - 1 {
                if autoReverse {
                    direction = -1
                } else {
                    direction = 1
                    imageIndex = 0
                }
            }
            
            imageIndex += direction
        }.onChange(of: entity) { _ in
            imageIndex = 0
            direction = 1
        }
    }
}

#Preview {
    MenuBarRunnerView(width: 22, height: 22).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

func clamp<T: Comparable>(_ value: T, lowerBound: T, upperBound: T) -> T {
    return min(max(value, lowerBound), upperBound)
}
