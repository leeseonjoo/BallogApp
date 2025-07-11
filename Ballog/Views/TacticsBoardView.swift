import SwiftUI
import UniformTypeIdentifiers

// Codable wrappers for Color and CGPoint
private struct ColorData: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
}

private extension Color {
    init(_ data: ColorData) {
        self.init(.sRGB, red: data.red, green: data.green, blue: data.blue, opacity: data.opacity)
    }
    var data: ColorData {
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return ColorData(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}

private struct PointData: Codable {
    var x: Double
    var y: Double
}

private extension CGPoint {
    init(_ data: PointData) {
        self.init(x: data.x, y: data.y)
    }
    var data: PointData { PointData(x: x, y: y) }
}

// Models
private struct PlayerIcon: Identifiable, Codable {
    var id = UUID()
    var name: String
    var color: ColorData
    var position: PointData
}

private struct TacticLine: Identifiable, Codable {
    var id = UUID()
    var start: PointData
    var end: PointData
    var color: ColorData
    var dashed: Bool
}

private struct TacticsState: Codable {
    var players: [PlayerIcon]
    var lines: [TacticLine]
}

/// Tactics board using SwiftUI `Canvas` for drawing lines.
struct TacticsBoardView: View {
    enum DrawMode { case none, pass, move }

    @State private var players: [PlayerIcon] = []
    @State private var lines: [TacticLine] = []
    @State private var undoneLines: [TacticLine] = []

    @State private var drawMode: DrawMode = .none
    @State private var selectedLineColor: Color = .red
    @State private var tempLine: TacticLine?

    @State private var selectedPlayerIndex: Int?
    @State private var isDraggingPlayer = false

    private let paletteTeams: [(String, Color)] = [
        ("A", .red),
        ("B", .blue)
    ]

    private let storageKey = "TacticsBoardState"

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack {
                    Image("tactics")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.width)

                    Canvas { context, _ in
                        for line in lines {
                            draw(line: line, in: &context)
                        }
                        if let line = tempLine { draw(line: line, in: &context) }
                    }
                    .simultaneousGesture(drawingGesture)

                    ForEach(players.indices, id: \.self) { index in
                        let binding = $players[index]
                        PlayerView(player: binding)
                            .position(CGPoint(players[index].position))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        isDraggingPlayer = true
                                        binding.position.wrappedValue = value.location.data
                                    }
                                    .onEnded { _ in
                                        isDraggingPlayer = false
                                    }
                            )
                            .onTapGesture {
                                selectedPlayerIndex = index
                            }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
                .onDrop(of: [UTType.plainText], isTargeted: nil) { providers, location in
                    dropPlayer(from: providers, at: location)
                }
            }
            controls
        } 
        .onAppear { reset() }
    }

    private var controls: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ColorPicker("", selection: $selectedLineColor).labelsHidden()
                Button("패스") { drawMode = .pass }
                Button("이동") { drawMode = .move }
                ForEach(paletteTeams, id: \.0) { team, color in
                    PalettePlayerView(name: team, color: color)
                        .onDrag { NSItemProvider(object: NSString(string: team)) }
                }
                Button("Undo") { undo() }
                Button("Redo") { redo() }
                Button("Reset") { reset() }
                Button("Save") { saveState() }
                Button("Load") { loadState() }
                if let index = selectedPlayerIndex {
                    ColorPicker("", selection: Binding(
                        get: { Color(players[index].color) },
                        set: { color in players[index].color = color.data }
                    )).labelsHidden()
                }
            }
            .font(.caption)
            .padding(.horizontal)
        }
    }

    private func draw(line: TacticLine, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(line.start))
        path.addLine(to: CGPoint(line.end))
        var style = StrokeStyle(lineWidth: 2)
        if line.dashed { style.dash = [6, 6] }
        context.stroke(path, with: .color(Color(line.color)), style: style)
    }

    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard drawMode != .none && !isDraggingPlayer else { return }
                if tempLine == nil {
                    tempLine = TacticLine(start: value.location.data, end: value.location.data, color: selectedLineColor.data, dashed: drawMode == .move)
                } else {
                    tempLine?.end = value.location.data
                }
            }
            .onEnded { value in
                guard drawMode != .none && !isDraggingPlayer else { tempLine = nil; return }
                if var line = tempLine {
                    line.end = value.location.data
                    lines.append(line)
                    undoneLines.removeAll()
                }
                tempLine = nil
            }
    }

    private func dropPlayer(from providers: [NSItemProvider], at location: CGPoint) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: String.self) {
                _ = provider.loadObject(ofClass: String.self) { team, _ in
                    if let team = team {
                        DispatchQueue.main.async {
                            addPlayer(team: team, at: location)
                        }
                    }
                }
                return true
            }
        }
        return false
    }

    private func addPlayer(team: String, at location: CGPoint) {
        let color: Color = team == "A" ? .red : .blue
        let count = players.filter { $0.name.hasPrefix(team) }.count + 1
        let newPlayer = PlayerIcon(name: "\(team)\(count)", color: color.data, position: location.data)
        players.append(newPlayer)
    }

    private func undo() { if let line = lines.popLast() { undoneLines.append(line) } }
    private func redo() { if let line = undoneLines.popLast() { lines.append(line) } }
    private func reset() {
        lines.removeAll()
        undoneLines.removeAll()
        players = Self.defaultPlayers
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func saveState() {
        let state = TacticsState(players: players, lines: lines)
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadState() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(TacticsState.self, from: data) else {
            players = Self.defaultPlayers
            return
        }
        players = state.players
        lines = state.lines
    }

    private static var defaultPlayers: [PlayerIcon] { [] }
}

private struct PlayerView: View {
    @Binding var player: PlayerIcon

    var body: some View {
        Circle()
            .fill(Color(player.color))
            .frame(width: 36, height: 36)
            .overlay(
                Text(player.name)
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
}

private struct PalettePlayerView: View {
    var name: String
    var color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 36, height: 36)
            .overlay(
                Text(name)
                    .font(.caption2)
                    .foregroundColor(.white)
            )
    }
}

#Preview {
    TacticsBoardView()
        .frame(width: 300, height: 360)
}
