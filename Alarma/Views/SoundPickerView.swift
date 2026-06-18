import SwiftUI
import AudioToolbox

struct SoundPickerView: View {
    @Binding var selectedSound: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(AlarmSound.SoundCategory.allCases, id: \.rawValue) { category in
                    Section(header:
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.accentBlue)
                    ) {
                        ForEach(AlarmSound.sounds(for: category)) { sound in
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
                                    AudioService.shared.playPreview(sound.systemSoundID)
                                } label: {
                                    Image(systemName: "play.circle")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.borderless)

                                Text(sound.toneConfig.pattern.rawValue.prefix(4))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 32)
                            }
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
        }
    }
}
