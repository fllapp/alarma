import SwiftUI

struct DaySelectorView: View {
    @Binding var days: Set<Int>

    private let dayNames = ["Dom", "Lun", "Mar", "Mie", "Jue", "Vie", "Sab"]
    private let dayNumbers = [1, 2, 3, 4, 5, 6, 7]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(zip(dayNames, dayNumbers)), id: \.1) { name, num in
                Button {
                    if days.contains(num) {
                        days.remove(num)
                    } else {
                        days.insert(num)
                    }
                } label: {
                    Text(name)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(minWidth: 38, minHeight: 36)
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
}
