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
                            Button {
                                selectedSound = sound.id
                                AudioServicesPlaySystemSound(sound.systemSoundID)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    dismiss()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selectedSound == sound.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedSound == sound.id ? .blue : .gray)
                                    Text(sound.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "play.circle")
                                        .foregroundColor(.gray)
                                }
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
