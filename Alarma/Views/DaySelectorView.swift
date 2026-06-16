import SwiftUI

struct DaySelectorView: View {
    @Binding var days: Set<Int>

    private let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    private let dayNumbers = [1, 2, 3, 4, 5, 6, 7]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(zip(dayNames, dayNumbers)), id: \.1) { name, num in
                Button {
                    toggleDay(num)
                } label: {
                    Text(name)
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 38, height: 36)
                        .background(days.contains(num) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(days.contains(num) ? .white : .white.opacity(0.7))
                        .cornerRadius(18)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private func toggleDay(_ day: Int) {
        if days.contains(day) {
            days.remove(day)
        } else {
            days.insert(day)
        }
    }
}
