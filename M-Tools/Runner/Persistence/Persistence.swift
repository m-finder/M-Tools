//
//  Persistence.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import AppKit
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "M_Tools")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // gif 初始化
        let _ = fillWithDefaultRunner(context: container.viewContext)
        // diy 初始化
        let _ = createDefaultDiyRunner(context: container.viewContext)
    }
    
    init(url: URL) {
        container = NSPersistentCloudKitContainer(name: "M_Tools")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    
    func defaultRunner() -> [String : (String, String)] {
        return [
            "mario": ("A1AF9595-F3FC-4A4F-A134-8F9CED4B761D", "default"),
            "face": ("A2AF9595-F3FC-4A4F-A134-8F9CED4B761D", "default"),
            "eugene": ("A3AF9595-F3FC-4A4F-A134-8F9CED4B767D", "default"),
            "bob": ("A4AF9595-F3FC-4A4F-A134-8F9CED4B767D", "default"),
            "pikachu": ("A5AF9595-F3FC-4A4F-A134-8F9CED4B767D", "default"),
            "girl": ("A6AF9595-F3FC-4A4F-A134-8F9CED4B767D", "default"),
            "batman": ("A7AF9595-F3FC-4A4F-A134-8F9CED4B767D", "default"),
        ]
    }
    
    func fillWithDefaultRunner(context: NSManagedObjectContext) -> Int {

        guard let urls = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: nil) else {
            return 0
        }
        
        let defaultRunners = defaultRunner()
        
        var count = 0
        for url in urls {
            
            let name = url.deletingPathExtension().lastPathComponent
            guard let conf = defaultRunners[name] else {
                continue
            }
            
            let _ = createNewRunner(
                context: context,
                id: UUID(uuidString: conf.0)!,
                type: conf.1,
                data: (try? Data(contentsOf: url))!
            )
            count += 1
        }
        
        return count
    }
    
    func createNewRunner(context: NSManagedObjectContext, id: UUID, type: String, data: Data) -> RunnerEntity {
        
        let rq = RunnerEntity.fetchRequest()
        rq.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        guard let res = try? context.fetch(rq) else {
            fatalError("Runner出现了问题")
        }
        
        if !res.isEmpty {
            return res.first!
        }
        
        let newRunner = RunnerEntity(context: context)
        _ = newRunner.setGIF(data: data)
        newRunner.id = id
        newRunner.type = type

        return newRunner
    }
    
    func createDefaultDiyRunner(context: NSManagedObjectContext) -> RunnerEntity {
        let rq = RunnerEntity.fetchRequest()
        rq.predicate = NSPredicate(format: "type == %@", "diy")
        
        guard let res = try? context.fetch(rq) else {
            fatalError("Runner出现了问题")
        }
        
        // 已存在直接取，不清空
        if !res.isEmpty {
            return res.first!
        }
        
        guard let url = Bundle.main.url(forResource: "mariohello", withExtension: "gif") else {
            fatalError("Lost Resources")
        }
        
        return createNewRunner(
            context: context,
            id: UUID(),
            type: "diy",
            data: (try? Data(contentsOf: url))!
        )
    }
    
    static func save(context: NSManagedObjectContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


extension RunnerEntity {
    static var defaultImage = #imageLiteral(resourceName: "AppLogo").cgImage(forProposedRect: nil, context: nil, hints: nil)!
    static var imgCache = [RunnerEntity:[Int:CGImage]]()
    
    private func getImageOptions() -> NSDictionary {
        return [
            kCGImageSourceShouldCache as String: NSNumber(value: true),
            kCGImageSourceTypeIdentifierHint as String: "com.compuserve.gif" // kUTTypeGIF
        ]
    }
    
    // 加载图片数据
    private func getCGImageSource(_ data: Data?) -> CGImageSource? {
        guard let rawData = data else {
            return nil
        }
        
        return CGImageSourceCreateWithData(NSData(data: rawData), getImageOptions())
    }
    
    // 统计数据帧数
    private func getRealFrameCount(_ data: Data?) -> Int {
        guard let imageSrc = getCGImageSource(data) else {
            return 0
        }
        
        return CGImageSourceGetCount(imageSrc)
    }
    
    // 设置数据填充
    func setGIF(data: Data) -> Bool {
        let num = getRealFrameCount(data)
        
        if num < 0 {
            return false
        }

        self.frame_num = Int32(num)
        self.data = data
        // 刷新缓存
        RunnerEntity.imgCache[self] = nil
        return true
    }

    func getImage(_ index: Int) -> CGImage {
        var index = index
        
        if RunnerEntity.imgCache[self] == nil {
            RunnerEntity.imgCache[self] = [Int:CGImage]()
        }
        
        let cacheList = RunnerEntity.imgCache[self]!
   
        
        if cacheList[index] == nil {
            if index >= self.frame_num || index < 0 {
                index = 0
            }
            
            guard let img_src = getCGImageSource(self.data) else {
                return RunnerEntity.defaultImage
            }
            
            guard let img = CGImageSourceCreateImageAtIndex(img_src, index, getImageOptions()) else {
                return RunnerEntity.defaultImage
            }
            RunnerEntity.imgCache[self]![index] = img
        }
        
        return RunnerEntity.imgCache[self]![index]!
    }
}
