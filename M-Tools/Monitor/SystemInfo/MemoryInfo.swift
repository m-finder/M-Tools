//
//  MemoryInfo.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import Foundation

class MemoryInfo: ObservableObject {
    
    private let gigaByte: Double = 1_073_741_824 // 2^30
    private let hostVmInfo64Count: mach_msg_type_number_t!
    private let hostBasicInfoCount: mach_msg_type_number_t!
    
    @Published private var memoryUsage: Double = 0.0
    @Published private var memoryPressure: Double = 0.0
    @Published private var memoryApp: Double = 0.0
    @Published private var memoryWired: Double = 0.0
    @Published private var memoryCompressed: Double = 0.0
    
    init() {
        hostVmInfo64Count = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        hostBasicInfoCount = UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    
    private var maxMemory: Double {
        var size: mach_msg_type_number_t = hostBasicInfoCount
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        let _ = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int()) { (pointer) -> kern_return_t in
            return host_info(mach_host_self(), HOST_BASIC_INFO, pointer, &size)
        }
        let data = hostInfo.move()
        hostInfo.deallocate()
        return Double(data.max_mem) / gigaByte
    }
    
    private var vmStatistics64: vm_statistics64 {
        var size: mach_msg_type_number_t = hostVmInfo64Count
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)
        let _ = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { (pointer) -> kern_return_t in
            return host_statistics64(mach_host_self(), HOST_VM_INFO64, pointer, &size)
        }
        let data = hostInfo.move()
        hostInfo.deallocate()
        return data
    }
    
    private func update() {
        let maxMem = maxMemory
        let load = vmStatistics64
        
        let unit        = Double(vm_kernel_page_size) / gigaByte
        let active      = Double(load.active_count) * unit
        let speculative = Double(load.speculative_count) * unit
        let inactive    = Double(load.inactive_count) * unit
        let wired       = Double(load.wire_count) * unit
        let compressed  = Double(load.compressor_page_count) * unit
        let purgeable   = Double(load.purgeable_count) * unit
        let external    = Double(load.external_page_count) * unit
        let using       = active + inactive + speculative + wired + compressed - purgeable - external
        
        memoryUsage = min(99.9, (100.0 * using / maxMem))
        memoryPressure = (100.0 * (wired + compressed) / maxMem)
        memoryApp        = (using - wired - compressed)
        memoryWired = wired
        memoryCompressed = compressed
    }
    
    public func getUsageValue() -> Double {
        memoryUsage
    }
    
    public func getPressrureValue() -> Double {
        memoryPressure
    }
    
    public func getAppValue() -> Double {
        memoryApp
    }
    
    public func getWiredValue() -> Double {
        memoryWired
    }
    
    public func getCpmpressed() -> Double {
        memoryCompressed
    }
}
