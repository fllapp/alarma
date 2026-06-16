import SwiftUI

struct AlarmActiveView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: Alarm
    let isUltimatum: Bool

    @State private var userAnswer = ""
    @State private var showError = false
    @State private var problem: MathProblem?
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Fondo dinámico
            Color.black.ignoresSafeArea()
            
            if isUltimatum {
                Circle()
                    .fill(AppColors.accentRed.opacity(0.2))
                    .scaleEffect(pulseScale)
                    .frame(width: 400, height: 400)
                    .blur(radius: 50)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).repeatForever()) {
                            pulseScale = 1.5
                        }
                    }
            }

            VStack(spacing: 32) {
                if isUltimatum {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.accentRed)
                        Text("SISTEMA DE ULTIMÁTUM")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.accentRed)
                    }
                    .padding(.top, 60)
                }

                VStack(spacing: 8) {
                    Text(alarm.title)
                        .font(.title2)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(alarm.timeString)
                        .font(AppFonts.timeFont(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.2), radius: 20)
                }

                Spacer()

                if let problem = problem {
                    VStack(spacing: 24) {
                        Text("Cálculo de Seguridad")
                            .font(.headline)
                            .foregroundColor(AppColors.textSecondary)

                        Text(problem.question)
                            .font(AppFonts.timeFont(size: 48))
                            .foregroundColor(.white)
                            .padding(.vertical, 30)
                            .padding(.horizontal, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(AppColors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )

                        HStack(spacing: 20) {
                            TextField("?", text: $userAnswer)
                                .keyboardType(.numberPad)
                                .font(AppFonts.timeFont(size: 32))
                                .multilineTextAlignment(.center)
                                .frame(width: 150)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                                .foregroundColor(.white)

                            Button("OK") {
                                submitAnswer()
                            }
                            .font(.title3.bold())
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(AppColors.accentBlue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.accentBlue.opacity(0.4), radius: 10)
                        }

                        if showError {
                            Text("❌ Respuesta incorrecta")
                                .foregroundColor(AppColors.accentRed)
                                .font(.subheadline.bold())
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 30)
                }

                Spacer()

                HStack(spacing: 60) {
                    Button {
                        alarmManager.snoozeAlarm()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 48))
                            Text("Posponer")
                                .font(.caption.bold())
                        }
                        .foregroundColor(AppColors.accentOrange)
                    }
                    .disabled(isUltimatum)
                    .opacity(isUltimatum ? 0.3 : 1)
                }
                .padding(.bottom, 60)
            }
            .padding()
        }
        .onAppear {
            problem = MathService.shared.generateProblem(difficulty: alarm.mathDifficulty)
        }
    }

    private func submitAnswer() {
        guard let answer = Int(userAnswer) else {
            withAnimation { showError = true }
            return
        }
        let correct = alarmManager.checkMathAnswer(answer)
        if correct {
            userAnswer = ""
            showError = false
        } else {
            withAnimation { showError = true }
            userAnswer = ""
        }
    }
}

struct MathChallengeView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: Alarm

    var body: some View {
        AlarmActiveView(alarm: alarm, isUltimatum: false)
            .environmentObject(alarmManager)
    }
}
