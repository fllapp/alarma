import SwiftUI
import UniformTypeIdentifiers

struct SoundPickerView: View {
    @Binding var selectedSound: String
    @Environment(\.dismiss) private var dismiss
    @State private var showFilePicker = false

    private var allCategories: [AlarmSound.SoundCategory] {
        var cats = AlarmSound.SoundCategory.allCases.filter { $0 != .custom }
        if !AlarmManager.shared.customSounds.isEmpty {
            cats.append(.custom)
        }
        return cats
    }

    private func soundsFor(_ category: AlarmSound.SoundCategory) -> [AlarmSound] {
        if category == .custom {
            return AlarmManager.shared.customSounds
        }
        return AlarmSound.sounds(for: category)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(allCategories, id: \.rawValue) { category in
                    let sounds = soundsFor(category)
                    if !sounds.isEmpty {
                        Section(header:
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(AppColors.accentBlue)
                        ) {
                            ForEach(sounds) { sound in
                                HStack {
                                    Button {
                                        selectedSound = sound.id
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedSound == sound.id ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedSound == sound.id ? .blue : .gray)
                                            Text(sound.name)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                    }

                                    Button {
                                        AudioService.shared.playPreviewSound(sound.id)
                                    } label: {
                                        Image(systemName: "play.circle")
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    }
                                    .buttonStyle(.borderless)

                                    if category == .custom {
                                        Button {
                                            AlarmManager.shared.deleteCustomSound(sound)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.title3)
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Importar MP3")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Sonidos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.audio, .mp3],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        guard url.startAccessingSecurityScopedResource() else { return }
                        defer { url.stopAccessingSecurityScopedResource() }
                        AlarmManager.shared.importCustomSound(from: url)
                    }
                case .failure:
                    break
                }
            }
        }
    }
}
