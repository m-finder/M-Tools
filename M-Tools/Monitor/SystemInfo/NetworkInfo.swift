//
//  NetworkInfo.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/23.
//

import Foundation
import SystemConfiguration

class NetworkInfo: ObservableObject {
    private var previousUpload: Int64 = 0
    private var previousDownload: Int64 = 0
    private var previousIP: String = "xx.x.x.xx"
    private var interval: Double = 1.0

    @Published private var uploadSpeed: Double = 0.0
    @Published private var downloadSpeed: Double = 0.0
    @Published private var ipAddress: String = "xx.x.x.xx"

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.update(interval: self.interval)
            }
        }
    }

    private var getDefaultID: String? {
        let processName = ProcessInfo.processInfo.processName as CFString
        let dynamicStore = SCDynamicStoreCreate(kCFAllocatorDefault, processName, nil, nil)
        let ipv4Key = SCDynamicStoreKeyCreateNetworkGlobalEntity(kCFAllocatorDefault,
                kSCDynamicStoreDomainState,
                kSCEntNetIPv4)
        guard let list = SCDynamicStoreCopyValue(dynamicStore, ipv4Key) as? [CFString: Any],
              let interface = list[kSCDynamicStorePropNetPrimaryInterface] as? String
        else {
            return nil
        }
        return interface
    }

    private func getBytesInfo(
            _ id: String,
            _ pointer: UnsafeMutablePointer<ifaddrs>
    ) -> (up: Int64, down: Int64)? {
        let name = String(cString: pointer.pointee.ifa_name)
        if name == id {
            let addr = pointer.pointee.ifa_addr.pointee
            guard addr.sa_family == UInt8(AF_LINK) else {
                return nil
            }
            var data: UnsafeMutablePointer<if_data>? = nil
            data = unsafeBitCast(pointer.pointee.ifa_data,
                    to: UnsafeMutablePointer<if_data>.self)
            return (up: Int64(data?.pointee.ifi_obytes ?? 0),
                    down: Int64(data?.pointee.ifi_ibytes ?? 0))
        }
        return nil
    }
    
    private func getIPAddress(
            _ id: String,
            _ pointer: UnsafeMutablePointer<ifaddrs>
        ) -> String? {
            let name = String(cString: pointer.pointee.ifa_name)
            if name == id {
                var addr = pointer.pointee.ifa_addr.pointee
                guard addr.sa_family == UInt8(AF_INET) else { return nil }
                var ip = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(&addr, socklen_t(addr.sa_len), &ip,
                            socklen_t(ip.count), nil, socklen_t(0), NI_NUMERICHOST)
                return String(cString: ip)
            }
            return nil
        }
    
    private func update(interval: Double) {
        self.interval = max(interval, 1.0)
        guard let id = getDefaultID else {
            return
        }
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else { return }

        var pointer = ifaddr
        var upload: Int64 = 0
        var download: Int64 = 0
        
        while pointer != nil {
            defer { pointer = pointer?.pointee.ifa_next }
            if let info = getBytesInfo(id, pointer!) {
                upload += info.up
                download += info.down
            }
            
            if let ip = getIPAddress(id, pointer!) {
                if previousIP != ip {
                    previousUpload = 0
                    previousDownload = 0
                }
                previousIP = ip
                ipAddress = ip
            }
        }

        freeifaddrs(ifaddr)
        if previousUpload != 0 && previousDownload != 0 {
            uploadSpeed = Double(upload - previousUpload) / interval
            downloadSpeed = Double(download - previousDownload) / interval
        }
        previousUpload = upload
        previousDownload = download
    }

    private func convert(byte: Double) -> PacketData {
        let KB: Double = 1024
        let MB: Double = pow(KB, 2)
        let GB: Double = pow(KB, 3)
        let TB: Double = pow(KB, 4)
        if TB <= byte {
            return PacketData(value: (byte / TB), unit: "TB/s")
        } else if GB <= byte {
            return PacketData(value: (byte / GB), unit: "GB/s")
        } else if MB <= byte {
            return PacketData(value: (byte / MB), unit: "MB/s")
        } else {
            return PacketData(value: (byte / KB), unit: "KB/s")
        }
    }

    public func getUploadSpeed() -> PacketData {
        convert(byte: uploadSpeed)
    }

    public func getDownloadSeed() -> PacketData {
        convert(byte: downloadSpeed)
    }
    
    public func getIpAddress() -> String {
        ipAddress
    }
}

public struct PacketData {
    public var value: Double
    public var unit: String
}
