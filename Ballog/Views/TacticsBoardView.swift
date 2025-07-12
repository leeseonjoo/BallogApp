import SwiftUI

struct TacticIcon: Identifiable {
    let id = UUID()
    let imageName: String
    var color: Color = .primary
    var position: CGPoint
    var dashed: Bool = false
}

struct TacticsBoardView: View {
    @State private var icons: [TacticIcon] = [
        TacticIcon(imageName: "soccerball", position: CGPoint(x: 150, y: 150)),
        // Red players
        TacticIcon(imageName: "person.fill", color: .red, position: CGPoint(x: 50, y: 50)),
        TacticIcon(imageName: "person.fill", color: .red, position: CGPoint(x: 50, y: 250)),
        TacticIcon(imageName: "person.fill", color: .red, position: CGPoint(x: 100, y: 100)),
        TacticIcon(imageName: "person.fill", color: .red, position: CGPoint(x: 100, y: 200)),
        // Blue players
        TacticIcon(imageName: "person.fill", color: .blue, position: CGPoint(x: 250, y: 50)),
        TacticIcon(imageName: "person.fill", color: .blue, position: CGPoint(x: 250, y: 250)),
        TacticIcon(imageName: "person.fill", color: .blue, position: CGPoint(x: 300, y: 100)),
        TacticIcon(imageName: "person.fill", color: .blue, position: CGPoint(x: 300, y: 200))
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("tactics")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.width)

                ForEach($icons) { $icon in
                    Image(systemName: icon.imageName)
                        .resizable()
                        .foregroundColor(icon.color)
                        .frame(width: 24, height: 24)
                        .position(icon.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    icon.position = value.location
                                }
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
}

#Preview {
    TacticsBoardView()
        .frame(width: 300, height: 300)
}
