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

    var body: some View {
        NavigationStack {
            VStack {
                if searchActive {
                    searchResultsSection
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            favoritesSection
                            allLinksSection
                        }
                        .padding()
                    }
                }
            }
            .searchable(text: $searchText, isPresented: $searchActive, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for people, clients, matters")
            .onChange(of: searchText) { oldValue, newValue in
                searchActive = !newValue.isEmpty
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                if searchActive {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            searchText = ""
                            searchActive = false
                        }
                    }
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
            } else {}
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
        VStack {
            List(filteredLinks) { link in
                HStack {
                    Image(systemName: iconFor(type: link.type))
                        .foregroundColor(colorFor(type: link.type))
                    Text(link.name)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundColor(Color.blue)
                }
                .padding()
                .onTapGesture {
                    handleLinkAction(link)
                }
            }
            .listStyle(PlainListStyle())
        }
    }

    var filteredLinks: [QuickLink] {
        if searchText.isEmpty {
            return quickLinks
        } else {
            return quickLinks.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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

    func colorFor(type: String) -> Color {
        switch type {
        case "Dashboard":
            return .blue
        case "URL":
            return .green
        case "Access Required":
            return .gray
        default:
            return .secondary
        }
    }

    func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
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

