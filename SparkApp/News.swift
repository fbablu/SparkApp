import SwiftUI

struct News: View {
    @State private var showFavorites = false
    @State private var titleVisible = true

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(NewsSections.allCases, id: \.self) { section in
                        Section(header: Text(section.rawValue).font(.headline)) {
                            ForEach(newsItems.filter { $0.section == section && (!showFavorites || $0.isFavorite) }, id: \.id) { item in
                                NewsItemView(item: item)
                            }
                        }
                    }
                }
                .padding()
            }

            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    LazyHStack {
                        if titleVisible {
                            Text("News")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
            }
            .toolbar {
                Button(action: {
                    showFavorites.toggle()
                }) {
                    Image(systemName: showFavorites ? "star.fill" : "star")
                }
            }
        }
        .tabItem {
            Label("News", systemImage: "newspaper")
        }
        
    }
}

struct NewsItemView: View {
    @State var item: NewsItem

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(
                    Text(item.title)
                        .padding()
                )

            Button(action: {
                item.isFavorite.toggle()
            }) {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
    }
}

enum NewsSections: String, CaseIterable {
    case news = "News"
    case recognitions = "Recognitions"
    case publications = "Publications"
    case blogs = "Blogs"
    case podcasts = "Podcasts"
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let section: NewsSections
    var isFavorite: Bool = false
}

let newsItems: [NewsItem] = [
    NewsItem(title: "New Legal Framework Announced", section: .news),
    NewsItem(title: "Employee of the Month: Jane Doe", section: .recognitions),
    NewsItem(title: "Recent Developments in Copyright Law", section: .publications),
    NewsItem(title: "The Future of Legal Tech", section: .blogs),
    NewsItem(title: "Legal Ethics in the Digital Age", section: .podcasts),
    // Add more dummy data here
]

struct News_Previews: PreviewProvider {
    static var previews: some View {
        News()
    }
}
