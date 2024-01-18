//
//  ContentView.swift
//  CustomFileFormatTest
//
//  Created by Maks Winters on 18.01.2024.
//
// https://www.youtube.com/watch?v=Fg1VQsF1RQw&list=PLt46BtfcgiduiZ4StIPPzuD0vPcIZwKW_&index=60&t=291s
//
// https://www.hackingwithswift.com/quick-start/swiftdata/how-to-make-swiftdata-models-conform-to-codable
//
// https://www.hackingwithswift.com/quick-start/swiftdata/how-to-delete-a-swiftdata-object
//

import SwiftUI
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

extension UTType {
    static var teffExportType = UTType(exportedAs: "com.makswinters.CustomFileFormatTest.teff")
}

@Model
final class TestData: Codable, Transferable {
    
    static let dateFormatter = DateFormatter()
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case date
    }
    
    let id: UUID
    var name: String
    var date: Date
    var stringDate: String {
        let formatter = TestData.dateFormatter
        formatter.dateFormat = "MM/dd/yyyy"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .teffExportType)
            .suggestedFileName("Export\(Date())")
    }
    
    init(name: String, date: Date = .now) {
        self.id = UUID()
        self.name = name
        self.date = date
    }
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var testingData: [TestData]
    
    @State private var importingData = false
    @State private var importingAlert = false
    @State private var importItem: TestData?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(testingData) { test in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(test.name)
                            Text(test.stringDate)
                        }
                        Spacer()
                        ShareLink(item: test, preview: SharePreview(test.name, image: "globe"))
                            .font(.system(size: 10))
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            modelContext.delete(test)
                        }
                    }
                }
            }
            .navigationTitle("Share test")
            .alert("Import \(importItem?.name ?? "")?", isPresented: $importingAlert) {
                Button("Cancel") { }
                Button("Save") {
                    modelContext.insert(importItem!)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Generate random") {
                        let names = ["John", "Jane", "Bob", "Alice", "Charlie", "David", "Emily", "Frank", "Grace", "Henry"]
                        let newItem = TestData(name: names.randomElement()!)
                        modelContext.insert(newItem)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Import") {
                        importingData.toggle()
                    }
                }
            }
            .fileImporter(isPresented: $importingData, allowedContentTypes: [.teffExportType]) { result in
                switch result {
                case .success(let success):
                    do {
                        let data = try Data(contentsOf: success)
                        importItem = try JSONDecoder().decode(TestData.self, from: data)
                        importingAlert = true
                    } catch {
                        print(error.localizedDescription)
                    }
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
