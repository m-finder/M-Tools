//
//  AppDelegate.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate{
    
    // runner
    let persistenceController = PersistenceController.shared
    private var statusBarItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    
    // texter
    private var texterStatusItem: NSStatusItem?
    private let texterPopover = NSPopover()
    @AppStorage("showTexter") var showTexter: Bool = false
    
    // monitor
    @AppStorage("showCpu") var showCpu: Bool = false
    @AppStorage("showMemory") var showMemory: Bool = false
    @AppStorage("showBattery") var showBattery: Bool = false
    @AppStorage("showDisk") var showDisk: Bool = false
    @AppStorage("showNetwork") var showNetwork: Bool = false
    private var cpuStatusItem: NSStatusItem?
    private var memoryStatusItem: NSStatusItem?
    private var batteryStatusItem: NSStatusItem?
    private var diskStatusItem: NSStatusItem?
    private var networkStatusItem: NSStatusItem?
    
    // hidder
    private var hidderShowLength: CGFloat =  8
    private let hidderHiddenLength: CGFloat = 10000
    @AppStorage("showHidder") var showHidder: Bool = false
    private var hidderStatusItems: [NSStatusItem] = []
    private var timer:Timer? = nil
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupRunnerIcon()
        setupTexterIcon()

        if showCpu {
            setupCpuMonitorIcon()
        }
        
        if showMemory {
            setupMemoryMnoitorIcon()
        }
        
        if showBattery {
            setupBatteryMonitorIcon()
        }
        
        if showDisk {
            setupDiskMonitorIcon()
        }
        
        if showNetwork {
            setupNetworkMonitorIcon()
        }
        
        if showHidder {
            setupHidderIcon()
        }
        
        if showHidder {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.hidderCollapseMenuBar()
            })
        }
    }
    
    private func setupRunnerIcon() {
        let menuItem = NSMenuItem()
        menuItem.title = "设置"
        menuItem.target = self
        let menu = NSMenu()

        // texter menu
        let texterMenu = NSMenuItem(title: "Texter", action: #selector(toggleTexter(_:)), keyEquivalent: "")
        texterMenu.state = showTexter ? .on : .off
        menu.addItem(texterMenu)
        
        // monitor menu
        let monitorMenu = NSMenuItem(title: "Monitor", action: nil, keyEquivalent: "")
        let monitorSubMenu = NSMenu()
        
        let cpuMenu = NSMenuItem(title: "CPU", action: #selector(toogleCpu(_:)), keyEquivalent: "")
        cpuMenu.state = showCpu ? .on : .off
        
        let memoryMenu = NSMenuItem(title: "Memory", action: #selector(toogleMemory(_:)), keyEquivalent: "")
        memoryMenu.state = showMemory ? .on : .off
        
        let batteryMenu = NSMenuItem(title: "Battery", action: #selector(toogleBattery(_:)), keyEquivalent: "")
        batteryMenu.state = showBattery ? .on : .off
        
        let diskMenu = NSMenuItem(title: "Disk", action: #selector(toogleDisk(_:)), keyEquivalent: "")
        diskMenu.state = showDisk ? .on : .off
        
        let networkMenu = NSMenuItem(title: "Network", action: #selector(toogleNetwork(_:)), keyEquivalent: "")
        networkMenu.state = showNetwork ? .on : .off
        
        monitorSubMenu.addItem(cpuMenu)
        monitorSubMenu.addItem(memoryMenu)
        monitorSubMenu.addItem(batteryMenu)
        monitorSubMenu.addItem(diskMenu)
        monitorSubMenu.addItem(networkMenu)
        monitorMenu.submenu = monitorSubMenu
        menu.addItem(monitorMenu)
        
        // hidder menu
        let hidderMenu = NSMenuItem(title: "Hidder", action: #selector(toggleHidder(_:)), keyEquivalent: "")
        hidderMenu.state = showHidder ? .on : .off
        menu.addItem(hidderMenu)
        
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: String(localized: "Setting"), action: #selector(settingView), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: String(localized: "Quit App"), action: #selector(quit), keyEquivalent: "q"))
        
        // runner menu
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let contentView = MenuBarRunnerView(width: 26, height: 26).padding(5).environment(\.managedObjectContext, persistenceController.container.viewContext)
        let mainView = NSHostingView(rootView: contentView)
        mainView.frame = NSRect(x: 0, y: 0, width: 26, height: 26)
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = " "
        statusBarItem?.button?.addSubview(mainView)
        statusBarItem?.menu = menu
    }
    
    private func setupTexterIcon() {
        texterStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let hostingView = NSHostingView(rootView: TexterView().fixedSize().frame(height: 26).padding(5))
        
        texterStatusItem?.button?.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.topAnchor.constraint(equalTo: (texterStatusItem?.button!.topAnchor)!).isActive = true
        hostingView.bottomAnchor.constraint(equalTo: (texterStatusItem?.button!.bottomAnchor)!).isActive = true
        hostingView.leadingAnchor.constraint(equalTo: (texterStatusItem?.button!.leadingAnchor)!).isActive = true
        hostingView.trailingAnchor.constraint(equalTo: (texterStatusItem?.button!.trailingAnchor)!).isActive = true
        texterStatusItem?.button?.action = #selector(texterViewPopover)
        texterStatusItem?.button?.target = self

        texterPopover.behavior = .transient
        texterPopover.animates = true
        texterPopover.contentSize = .init(width: 350, height: 320)
        texterPopover.contentViewController = NSViewController()
        texterPopover.contentViewController?.view = NSHostingView(
            rootView: TexterPopoverView().frame(maxWidth: .infinity, maxHeight: .infinity).padding()
        )
    }
    
    private func setupCpuMonitorIcon() {
        cpuStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMonitorIconView(item: cpuStatusItem, view: AnyView(CpuView().padding(3)))
    }
    
    private func setupMemoryMnoitorIcon() {
        memoryStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMonitorIconView(item: memoryStatusItem, view: AnyView(MemoryView().padding(3)))
    }
    
    private func setupBatteryMonitorIcon() {
        batteryStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMonitorIconView(item: batteryStatusItem, view: AnyView(BatteryView().padding(3)))
    }
    
    private func setupDiskMonitorIcon() {
        diskStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMonitorIconView(item: diskStatusItem, view: AnyView(DiskView().padding(3)))
    }
    
    private func setupNetworkMonitorIcon() {
        networkStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMonitorIconView(item: networkStatusItem, view: AnyView(NetworkView().padding(3)))
    }
    
    private func setupMonitorIconView(item: NSStatusItem?, view: AnyView) {
        
        let hostingView = NSHostingView(rootView: view.fixedSize().frame(height: 26))
        
        item?.button?.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.topAnchor.constraint(equalTo: (item?.button!.topAnchor)!).isActive = true
        hostingView.bottomAnchor.constraint(equalTo: (item?.button!.bottomAnchor)!).isActive = true
        hostingView.leadingAnchor.constraint(equalTo: (item?.button!.leadingAnchor)!).isActive = true
        hostingView.trailingAnchor.constraint(equalTo: (item?.button!.trailingAnchor)!).isActive = true
//        item?.button?.action = #selector(menuBarClicked)
        item?.button?.target = self

//        let popover = NSPopover()
//        popover.behavior = .transient
//        popover.animates = true
//        popover.contentSize = .init(width: size.width, height: size.height)
//        popover.contentViewController = NSViewController()
//        popover.contentViewController?.view = NSHostingView(
//            rootView: popoverView.frame(maxWidth: .infinity, maxHeight: .infinity).padding()
//        )
//        popovers.append(popover)
    }
    
    private func setupHidderIcon() {
        setupHidderItem()
        setupHidderItem()
    }
    
    private func setupHidderItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let image = NSImage(named: NSImage.Name("Circle"))
            image?.size = NSSize(width: hidderShowLength, height: hidderShowLength)
            image?.isTemplate = true
            button.image = image
            button.target = self
            button.action = #selector(hidderClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        hidderStatusItems.append(statusItem)
    }
    
    @IBAction func settingView(_ sender: Any) {
        if settingsWindow == nil {
            let settingsView = SettingsView()
                .frame(width: 455, height: 580)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.title = String(localized: "Setting")
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("xxx")
            sender.orderOut(self)
            return false
        }
    
    @IBAction func quit(_ sender: Any){
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func toggleTexter(_ sender: NSMenuItem) {
        showTexter.toggle()
        sender.state = showTexter ? .on : .off
    }
    
    @IBAction func texterViewPopover(_ sender: NSStatusBarButton){
        if texterPopover.isShown {
            texterPopover.performClose(nil)
            return
        }
        texterPopover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        texterPopover.contentViewController?.view.window?.makeKey()
    }
    
    @IBAction func toogleCpu(_ sender: NSStatusBarButton){
        showCpu.toggle()
        sender.state = showCpu ? .on : .off
        if showCpu {
            setupCpuMonitorIcon()
        }else{
            if cpuStatusItem != nil {
                NSStatusBar.system.removeStatusItem(cpuStatusItem!)
            }
        }
    }
    
    @IBAction func toogleMemory(_ sender: NSStatusBarButton){
        showMemory.toggle()
        sender.state = showMemory ? .on : .off
        if showMemory {
            setupMemoryMnoitorIcon()
        }else{
            if memoryStatusItem != nil {
                NSStatusBar.system.removeStatusItem(memoryStatusItem!)
            }
        }
    }
    
    @IBAction func toogleBattery(_ sender: NSStatusBarButton){
        showBattery.toggle()
        sender.state = showBattery ? .on : .off
        if showBattery {
            setupBatteryMonitorIcon()
        }else{
            if batteryStatusItem != nil {
                NSStatusBar.system.removeStatusItem(batteryStatusItem!)
            }
        }
    }
    
    @IBAction func toogleDisk(_ sender: NSStatusBarButton){
        showDisk.toggle()
        sender.state = showDisk ? .on : .off
        if showDisk {
            setupDiskMonitorIcon()
        }else{
            if diskStatusItem != nil {
                NSStatusBar.system.removeStatusItem(diskStatusItem!)
            }
        }
    }
    
    @IBAction func toogleNetwork(_ sender: NSStatusBarButton){
        showNetwork.toggle()
        sender.state = showNetwork ? .on : .off
        if showNetwork {
            setupNetworkMonitorIcon()
        }else{
            if networkStatusItem != nil {
                NSStatusBar.system.removeStatusItem(networkStatusItem!)
            }
        }
    }
    
    @IBAction func toggleHidder(_ sender: NSStatusBarButton){
        showHidder.toggle()
        sender.state = showHidder ? .on : .off
        if showHidder {
            setupHidderIcon()
        }else {
            if hidderStatusItems.count > 0 {
                hidderStatusItems.removeAll()
            }
           
        }
    }
    
    @IBAction func hidderClick(_ sender: NSStatusBarButton) {
        // 从两个图标中获取靠左的一个，然后执行 toggle
        self.hidderCollapseMenuBar()
    }
    
    private func hidderCollapseMenuBar() {
        let leftItem = hidderStatusItems.min(by: { ($0.button?.window?.frame.origin.x)! < ($1.button?.window?.frame.origin.x)! })
        if leftItem?.length == hidderHiddenLength {
            leftItem?.length = hidderShowLength
        }else{
            leftItem?.length = hidderHiddenLength
        }
    }
    
    private func startTimerToAutoHide() {
        timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.hidderCollapseMenuBar()
            }
        }
    }
}
