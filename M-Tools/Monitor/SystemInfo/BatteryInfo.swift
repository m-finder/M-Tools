//
//  BatteryInfo.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import Foundation
import IOKit

class BatteryInfo: ObservableObject {

    @Published private var batteryUsage: Double = 0.0
    @Published private var powerSource: String = ""
    @Published private var cycle: Int = 0
    @Published private var temperatureValue: Double = 0.0
    @Published private var maxCapacityValue: Double = 0.0

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.update()
            }
        }
    }

    public func update() {

        var service: io_service_t = 0

        defer {
            IOServiceClose(service)
            IOObjectRelease(service)
        }

        // Open Connection
        service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceNameMatching("AppleSmartBattery"))
        if service == MACH_PORT_NULL {
            return
        }

        // Read Dictionary Data
        var props: Unmanaged<CFMutableDictionary>? = nil
        guard IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == kIOReturnSuccess,
              let dict = props?.takeUnretainedValue() as? [String: AnyObject]
        else {
            return
        }
        props?.release()

        if let maxCapacity = dict["MaxCapacity"] as? Double,
           let currentCapacity = dict["CurrentCapacity"] as? Double {
            #if arch(x86_64) // Intel Chip
            batteryUsage = 100.0 * currentCapacity / maxCapacity
            #elseif arch(arm64) // Apple Silicon Chip
            batteryUsage = currentCapacity
            maxCapacityValue = maxCapacity
            #endif
        }
        
        if let adapter = dict["AdapterDetails"] as? [String: AnyObject],
           let name = adapter["Name"] as? String {
            powerSource = name
        }
        if let cycleCount = dict["CycleCount"] as? Int {
            cycle = cycleCount
        }
        if let temperature = dict["Temperature"] as? Double {
            temperatureValue = temperature / 100.0
        }
        
    }

    public func getImage() -> String {
        if batteryUsage < 20.0 {
            return "battery.0"
        }
        switch batteryUsage {
        case 0.0...20.0:
            return "battery.0"
        case 20.0...25.0:
            return "battery.25"
        case 25.0...50.0:
            return "battery.50"

        case 50.0...75.0:
            return "battery.75"

        case 75.0...100.0:
            return "battery.100"

        default:
            return "battery.0"
        }
    }

    public func getUsageValue() -> Double {
        batteryUsage
    }
    
    public func getPowerSourceValue() -> String {
        powerSource
    }
    
    public func getMaxCapacityValue() -> Double {
        maxCapacityValue
    }
    
    public func getCycleValue() -> Int {
        cycle
    }
    
    public func getTemperatureValue() -> Double {
        temperatureValue
    }
}
