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
    @State private var showAllPeople = false
    @State private var quickLinks: [QuickLink] = []
    @State private var people: [Person] = []

    var body: some View {
        NavigationStack {
            VStack {
                if searchActive {
                    searchResultsSection
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            peopleSection
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
            }
        }
        .onAppear {
            quickLinks = loadQuickLinksFromCSV()
            people = loadPeopleFromJSON()
            print("Loaded \(people.count) people") // Add this line for debugging
        }
    }

    var peopleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("People")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(showAllPeople ? people : Array(people.prefix(5))) { person in
                        PersonCard(person: person)
                    }
                }
            }
            
            if people.isEmpty {
                Text("No people loaded")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(showAllPeople ? people : Array(people.prefix(5))) { person in
                            PersonCard(person: person)
                        }
                    }
                }
            }
            
            if !showAllPeople && people.count > 5 {
                Button("Show All") {
                    withAnimation {
                        showAllPeople = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
            }
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
            List {
                ForEach(filteredLinks) { link in
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
                
                ForEach(filteredPeople) { person in
                    HStack {
                        AsyncImage(url: URL(string: person.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(person.name)
                            Text(person.position)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color.blue)
                    }
                    .padding()
                    .onTapGesture {
                        if let url = URL(string: person.url) {
                            UIApplication.shared.open(url)
                        }
                    }
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

    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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
