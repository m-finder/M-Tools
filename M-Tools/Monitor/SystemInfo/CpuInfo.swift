//
//  CpuInfo.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import Foundation

class CpuInfo: ObservableObject {
    
    private var loadPrevious = host_cpu_load_info()
    
    @Published private var cpuUsage: Double = 0.0
    @Published private var cpuSystem: Double = 0.0
    @Published private var cpuUser: Double = 0.0
    @Published private var cpuIdle: Double = 0.0
    
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }
    
    
    private func hostCPULoadInfo() -> host_cpu_load_info {
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        
        let _ = hostInfo.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        return data
    }
    
    
    private func update() {
        
        let load = hostCPULoadInfo()
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let systemDiff = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        loadPrevious = load
        
        
        let totalTicks = systemDiff + userDiff + idleDiff + niceDiff
        let system = 100.0 * systemDiff / totalTicks
        let user = 100.0 * userDiff / totalTicks
        let idle = 100.0 * idleDiff / totalTicks
        
        cpuUsage = min(99.9, (system + user))
        cpuSystem = system
        cpuUser = user
        cpuIdle = idle
    }
    
    public func getUsageValue() -> Double {
        cpuUsage
    }
    
    public func getSystemValue() -> Double {
        cpuSystem
    }
    
    public func getUserValue() -> Double {
        cpuUser
    }
    
    public func getIdleValue() -> Double {
        cpuIdle
    }
    
}
