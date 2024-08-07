import SwiftUI
struct SparkButton: View {
    var action: () -> Void
    @State private var isPressed = false
    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .frame(width: 50, height: 60)
                .foregroundColor(.white)
                .background(isPressed ? Color.gray : Color.blue)
                .clipShape(Circle())
                .padding(.all, 20)
                .padding(.vertical, 20)
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in
                hapticFeedback()
            }
        )
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 0.5)
    }
}
