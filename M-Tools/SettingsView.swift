//
//  SettingsView.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import SwiftUI
import ServiceManagement
import UniformTypeIdentifiers

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RunnerEntity.id, ascending: true)],
        predicate: NSPredicate(format: "type == %@", "default"),
        animation: .easeInOut
    ) private var runners: FetchedResults<RunnerEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RunnerEntity.id, ascending: true)],
        predicate: NSPredicate(format: "type == %@", "diy"),
        animation: .easeInOut
    ) private var diyRunners: FetchedResults<RunnerEntity>
    
    @AppStorage("currentImageId") private var currentImageId: String = "A1AF9595-F3FC-4A4F-A134-8F9CED4B761D"
    @AppStorage("startUp") var startUp: Bool = false

    var body: some View {
        
        VStack(alignment: .center){
            FlowStack(spacing: CGSize(width: 10, height: 10)){
                ForEach(runners) { runner in
                    
                    VStack {
                        RunnerView(entity: runner, factor: currentImageId == runner.id?.uuidString ? 0.1 : 0.5)
                            .frame(width: 90, height: 90)
                            .cornerRadius(8)
                    }
                    .padding(4)
                    .background(Color.secondary.colorInvert())
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(currentImageId == runner.id?.uuidString ? Color.accentColor : Color.clear, lineWidth: 2))
                    .onTapGesture {
                        currentImageId = runner.id!.uuidString
                        _ = PersistenceController.save(context: viewContext)
                    }.id(runner.id!.uuidString)
                }
                
                ForEach(diyRunners) { diyRunner in
                    VStack {
                        RunnerView(entity: diyRunner, factor: currentImageId == diyRunner.id?.uuidString ? 0.1 : 0.5)
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                            .modifier(GifDropModifier(runner: diyRunner))
                            .onChange(of: diyRunner.data) { data in
                                currentImageId = diyRunner.id!.uuidString
                                _ = PersistenceController.save(context: viewContext)
                             
                            }

                        Text(String(localized: "Drag and drop GIF here.")).font(.caption)
                    }
                    
                    .frame(width: 90, height: 90)
                    .padding(4)
                    .background(Color.secondary.colorInvert())
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(currentImageId == diyRunner.id?.uuidString ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        currentImageId = diyRunner.id!.uuidString
                        _ = PersistenceController.save(context: viewContext)
                    }
                    .id(diyRunner.id!.uuidString)
                }
  

            }.padding(15)
            
            
            
            VStack(alignment: .center){
                Divider().padding(20)
                Toggle(String(localized: "Launch on Startup"), isOn: $startUp)
                    .onChange(of: startUp, perform: { newValue in
                        if newValue {
                            if SMAppService.mainApp.status == .enabled {
                                try? SMAppService.mainApp.unregister()
                            }
                            
                            try? SMAppService.mainApp.register()
                        } else {
                            try? SMAppService.mainApp.unregister()
                        }
                    })
                    .toggleStyle(SwitchToggleStyle())
                    .font(.system(size: 12))
                
                Button(String(localized: "Quit App")) {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .frame(width: 100, height: 40)
                .font(.body)
                .cornerRadius(10)
                
                Text("Made By M-finder 🚀")
                    .font(.footnote)
                    .fontWeight(.light)
                    .padding(.top)
                
                VStack(spacing: 1){
                    Text(String(localized: "The image is sourced from the internet."))
                        .font(.footnote)
                        .fontWeight(.light)
                    Text(String(localized: "Please contact us for removal if it infringes any copyrights."))
                        .font(.footnote)
                        .fontWeight(.light)
                }.padding(.top)
            }
        }
    }
}


#Preview {
    SettingsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
