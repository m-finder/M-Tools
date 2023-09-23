//
//  DiskInfo.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import Foundation

class DiskInfo: ObservableObject {

    @Published private var diskUsage: Double = 0
    @Published private var totalValue: Int64 = 0
    @Published private var freeValue: Int64 = 0
    @Published private var usedValue: Int64 = 0

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    
    private func convertByteData(byteCount: Int64) -> ByteData {
        let fmt = ByteCountFormatter()
        fmt.countStyle = .decimal
        let array = fmt.string(fromByteCount: byteCount)
            .replacingOccurrences(of: ",", with: ".")
            .components(separatedBy: .whitespaces)
        return ByteData(value: Double(array[0]) ?? 0.0, unit: array[1])
    }
    

    public func update() {
        let url = NSURL(fileURLWithPath: "/")
        let keys: [URLResourceKey] = [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey]
        guard let dict = try? url.resourceValues(forKeys: keys) else { return }
        let total = (dict[URLResourceKey.volumeTotalCapacityKey] as! NSNumber).int64Value
        let free = (dict[URLResourceKey.volumeAvailableCapacityForImportantUsageKey] as! NSNumber).int64Value
        let used: Int64 = total - free

        diskUsage = min(99.9, (100.0 * Double(used) / Double(total)))

        totalValue = total
        freeValue = free
        usedValue = total - free
    }

    public func getUsageValue() -> Double {
        diskUsage
    }
    
    public func getTotalValue() -> ByteData {
        convertByteData(byteCount: totalValue)
    }
    
    public func getFreeValue() -> ByteData {
        convertByteData(byteCount: freeValue)
    }
    
    public func getUsedValue() -> ByteData {
        convertByteData(byteCount: usedValue)
    }

}


public struct ByteData {
    public var value: Double
    public var unit: String
    
    public var description: String {
        return String(format: "%.2f %@", value, unit)
    }
}
