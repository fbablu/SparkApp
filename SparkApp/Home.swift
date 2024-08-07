//
//  Home.swift
//  SparkApp
//
//  Created by Fardeen Bablu on 8/4/24.
//

import SwiftUI
import Foundation
import SwiftData
import Combine

struct Home: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var searchText = ""
    @State private var searchActive = false
    @FocusState private var isSearchFocused: Bool
    @State private var showAllLinks = false
    @State private var quickLinks: [QuickLink] = []


    private var listofCountry = countryList
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !searchActive {
                        favoritesSection
                        allLinksSection
                    } else {
                        searchResultsSection
                    }
                }
                .padding()
            }
            .searchable(text: $searchText, isPresented: $searchActive)
            .onChange(of: searchActive, initial: true) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    isSearchFocused = true
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
        .tag(1)
        .overlay(alignment: .bottomTrailing) {
            if !searchActive {
                SparkButton {
                    withAnimation {
                        searchActive = true
                    }
                    hapticFeedback()
                }
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            quickLinks = loadQuickLinksFromCSV()
        }
    }
    
    var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Favorites")
                .font(.headline)
            Text("Viewable Examples")
                .font(.subheadline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(quickLinks.filter { $0.type == "Dashboard" }) { link in
                    QuickLinkButton(link: link, icon: "chart.bar")
                }
            }
            Text("URL Redirects")
                .font(.subheadline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(quickLinks.filter { $0.type == "URL" }) { link in
                    QuickLinkButton(link: link, icon: "link")
                }
            }
        }
    }
    var allLinksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All Links")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(showAllLinks ? quickLinks : Array(quickLinks.prefix(5))) { link in
                    QuickLinkButton(link: link, icon: iconFor(type: link.type))
                }
            }
            
            if !showAllLinks && quickLinks.count > 5 {
                Button("Show All") {
                    withAnimation {
                        showAllLinks = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
            }
        }
    }
    
    var searchResultsSection: some View {
        List {
            ForEach(countries, id: \.self) { country in
                HStack {
                    Text(country.capitalized)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(Color.blue)
                }
                .padding()
            }
        }
    }
    
    func iconFor(type: String) -> String {
        switch type {
        case "Dashboard":
            return "chart.bar"
        case "URL":
            return "link"
        case "Access Required":
            return "lock"
        default:
            return "questionmark.circle"
        }
    }
    
    func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    var countries: [String] {
        let lcCountries = listofCountry.map { $0.lowercased() }
        return searchText.isEmpty ? lcCountries : lcCountries.filter { $0.contains(searchText.lowercased()) }
    }
}

struct QuickLinkButton: View {
    let link: QuickLink
    let icon: String
    
    var body: some View {
        Button(action: {
            handleLinkAction(link)
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                Text(link.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(backgroundColorFor(type: link.type))
        .cornerRadius(10)
    }
    
    func backgroundColorFor(type: String) -> Color {
        switch type {
        case "Dashboard":
            return Color.blue.opacity(0.1)
        case "URL":
            return Color.green.opacity(0.1)
        case "Access Required":
            return Color.gray.opacity(0.1)
        default:
            return Color.secondary.opacity(0.1)
        }
    }
    
    func handleLinkAction(_ link: QuickLink) {
        switch link.type {
        case "Dashboard":
            // Show dashboard alert
            print("Show dashboard alert for \(link.name)")
        case "URL":
            if let url = URL(string: link.url ?? "") {
                UIApplication.shared.open(url)
            }
        case "Access Required":
            // Show access required alert
            print("Show access required alert for \(link.name)")
        default:
            print("Unknown link type for \(link.name)")
        }
    }
}
