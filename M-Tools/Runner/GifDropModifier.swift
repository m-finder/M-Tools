//
//  GifDropModifier.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct GifDropModifier: ViewModifier{
    @ObservedObject var runner: RunnerEntity
    
    func body(content: Content) -> some View {
        content.onDrop(of: [.fileURL], delegate: Delegate(runner))
    }
    
    struct Delegate: DropDelegate {
        var runner: RunnerEntity

        init(_ runner: RunnerEntity) {
            self.runner = runner
        }
        
        func getURLFromInfo(info: DropInfo) -> URL? {
            if !info.hasItemsConforming(to: [.fileURL]) {
                return nil
            }
            
            guard let provider = info.itemProviders(for: [.fileURL]).first else {
                return nil
            }
            var url_ret: URL? = nil
            let sema = DispatchSemaphore(value: 0)
            debugPrint(provider)
            
            if provider.canLoadObject(ofClass: NSURL.self) {
                provider.loadObject(ofClass: NSURL.self) { (url, error) in
                    defer {
                        sema.signal()
                    }
                    
                    guard error == nil else {
                        print("Error loading item: \(error!)")
                        return
                    }
                    
                    guard let url = url as? URL else {
                        return
                    }
                    
                    url_ret = url
                }
                sema.wait()
            }
            return url_ret
        }
        
        func validateDrop(info: DropInfo) -> Bool {
            if info.hasItemsConforming(to: [.gif]) {
                debugPrint("GIF get")
                return true
            }
            
            guard let url = getURLFromInfo(info: info) else {
                return false
            }
            
            let fileType = url.pathExtension.lowercased()
            
            debugPrint("File type: \(fileType)")
            let isGif = fileType == "gif"
            
            return isGif
        }
        
        func performDrop(info: DropInfo) -> Bool {
            let providers = info.itemProviders(for: [.fileURL, .gif])

            guard let provider = providers.first else {
                return false
            }
            
            if info.hasItemsConforming(to: [.gif]) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, error in
                    if let data = data {
                        let _ = runner.setGIF(data: data)
                    } else if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
            return true
        }
    }
}
