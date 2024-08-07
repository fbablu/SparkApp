//
//  csvToJSON.swift
//  SparkApp
//
//  Created by Fardeen Bablu on 8/7/24.
//

import Foundation

struct QuickLink: Codable, Identifiable {
    var id = UUID()
    let name: String
    let type: String
    let url: String?
    let description: String?
}

func loadQuickLinksFromCSV() -> [QuickLink] {
    guard let path = Bundle.main.path(forResource: "LinksData", ofType: "csv") else {
        print("CSV File not Found")
        return []
    }
    do {
        let csvString = try String(contentsOfFile: path, encoding: .utf8)
        let lines = csvString.components(separatedBy: .newlines)
        
        var quickLinks: [QuickLink] = []
        
        for line in lines.dropFirst() { // Skip header row
            let values = line.components(separatedBy: ",")
            guard values.count == 4 else { continue }
            
            let quickLink = QuickLink(
                name: values[0],
                type: values[1],
                url: values[2].isEmpty ? nil : values[2],
                description: values[3].isEmpty ? nil : values[3]
            )
            quickLinks.append(quickLink)
        }
        return quickLinks
    } catch {
        print("Error reading CSV file: \(error)")
        return []
    }
}

func convertQuickLinksToJSON(quickLinks: [QuickLink]) -> String? {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    
    do {
        let jsonData = try jsonEncoder.encode(quickLinks)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print("Error encoding to JSON: \(error)")
        return nil
    }
}

func testConverter() -> Void {
    let quickLinks = loadQuickLinksFromCSV()
    if !quickLinks.isEmpty {
        print("Loaded \(quickLinks.count) from CSV")
        print(quickLinks)
        
        if let jsonString = convertQuickLinksToJSON(quickLinks: quickLinks) {
            print("JSON representation")
            print(jsonString)
        }
    } else {
        print("Loading Failed")
    }
}
