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
    @State private var searchActive = falseit     @FocusState private var isSearchFocused: Bool
    private var listofCountry = countryList
    var body: some View {
        NavigationStack {
            VStack {
                if searchActive {
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
                } else {
                    // Quick Links Section
                    Section(header: Text("Quick Links").font(.headline)) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(quickLinks, id: \.title) { link in
                                Button(action: {
                                    // Action to open the link
                                }) {
                                    VStack {
                                        Image(systemName: link.icon)
                                            .font(.largeTitle)
                                        Text(link.title)
                                            .font(.caption)
                                    }
                                }
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
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
                    LazyHStack {
                        Text("Home")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            }
//            .navigationTitle("Home")

        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
        .tag(1)
        // Overlay Spark button
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
    }
    private var quickLinks: [(title: String, icon: String)] = [
        ("Company Portal", "building.2"),
        ("HR System", "person.text.rectangle"),
        ("Email", "envelope"),
        ("Calendar", "calendar"),
        ("Directory", "person.3"),
        ("IT Support", "laptopcomputer")
    ]
    // Filter elements
    var countries: [String] {
        let lcCountries = listofCountry.map { $0.lowercased() }
        return searchText.isEmpty ? lcCountries : lcCountries.filter { $0.contains(searchText.lowercased()) }
    }
    func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}
//struct SparkButton: View {
//    var action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Text("Spark")
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .clipShape(Circle())
//        }
//        .buttonStyle(.borderless)
//    }
//}
