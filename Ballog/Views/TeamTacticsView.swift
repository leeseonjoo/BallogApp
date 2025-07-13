import SwiftUI
import PhotosUI

struct TeamTacticsView: View {
    @EnvironmentObject private var tacticStore: TeamTacticStore
    @EnvironmentObject private var logStore: TeamTrainingLogStore
    @State private var showingForm = false
    @State private var selectedTactic: TeamTactic?

    private func count(for tactic: TeamTactic) -> Int {
        logStore.logs.values
            .flatMap { $0 }
            .filter { $0.tactic == tactic.name }
            .count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with + button
                HStack {
                    Text("전술 목록")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryText)
                    Spacer()
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.primaryBlue)
                            .font(.title2)
                    }
                }
                .padding(DesignConstants.horizontalPadding)
                .padding(.vertical, DesignConstants.verticalPadding)
                
                // Tactics List
                List {
                    ForEach(tacticStore.tactics) { tactic in
                        NavigationLink(destination: TeamTacticDetailView(tactic: tactic, count: count(for: tactic))) {
                            HStack {
                                Text(tactic.name)
                                Spacer()
                                Text("\(count(for: tactic))회")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete { tacticStore.remove(at: $0) }
                }
            }
            .sheet(isPresented: $showingForm) {
                TeamTacticFormView { tactic in
                    tacticStore.add(tactic)
                }
            }
        }
    }
}

struct TeamTacticDetailView: View {
    var tactic: TeamTactic
    var count: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(tactic.name)
                    .font(.title)
                Text("포메이션: \(tactic.formation)")
                if let data = tactic.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                Text(tactic.notes)
                Text("훈련 횟수: \(count)")
                Spacer()
            }
            .padding()
        }
        .navigationTitle(tactic.name)
    }
}

struct TeamTacticFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var formation = ""
    @State private var notes = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    var onSave: (TeamTactic) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("전술 이름", text: $name)
                TextField("포메이션", text: $formation)
                Section(header: Text("플레이 패턴")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text("이미지 선택")
                }
                if let data = imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            .navigationTitle("전술 추가")
            .toolbar {
                Button("저장") {
                    let tactic = TeamTactic(name: name, formation: formation, notes: notes, imageData: imageData)
                    onSave(tactic)
                    dismiss()
                }
            }
            .onChange(of: pickerItem) { newItem in
                if let newItem {
                    Task {
                        imageData = try? await newItem.loadTransferable(type: Data.self)
                    }
                }
            }
        }
    }
}

#Preview {
    TeamTacticsView()
        .environmentObject(TeamTacticStore())
        .environmentObject(TeamTrainingLogStore())
}
