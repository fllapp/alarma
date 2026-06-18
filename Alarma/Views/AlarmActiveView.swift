import SwiftUI

struct AlarmActiveView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: Alarm
    let isUltimatum: Bool

    @State private var userAnswer = ""
    @State private var showError = false
    @State private var pulseScale = 1.0
    @State private var dragOffset: CGFloat = 0
    @State private var showSnoozeHint = false

    private let snoozeThreshold: CGFloat = 120

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isUltimatum {
                Circle()
                    .fill(AppColors.accentRed.opacity(0.2))
                    .scaleEffect(pulseScale)
                    .frame(width: 400, height: 400)
                    .blur(radius: 50)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                            pulseScale = 1.5
                        }
                    }
            }

            VStack(spacing: 32) {
                if isUltimatum {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.accentRed)
                        Text("SISTEMA DE ULTIMATUM")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.accentRed)
                    }
                    .padding(.top, 60)
                }

                if alarm.gradualWakeUpDuration > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(AppColors.accentBlue)
                        Text("Despertar gradual")
                            .font(.caption.bold())
                            .foregroundColor(AppColors.accentBlue)
                    }
                    .padding(.top, 8)
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

                if alarm.mathEnabled {
                    if let problem = alarmManager.currentMathProblem {
                        VStack(spacing: 24) {
                            Text("Calculo de Seguridad")
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
                                Text("Respuesta incorrecta")
                                    .foregroundColor(AppColors.accentRed)
                                    .font(.subheadline.bold())
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                } else {
                    Button {
                        alarmManager.dismissAlarm()
                    } label: {
                        Text("DESACTIVAR ALARMA")
                            .font(.title2.bold())
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                            .background(AppColors.accentBlue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: AppColors.accentBlue.opacity(0.4), radius: 15)
                    }
                }

                Spacer()

                if alarm.snoozeStyle == .swipe && !isUltimatum {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.accentOrange.opacity(0.6))
                        Text("Desliza hacia arriba para posponer")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .opacity(showSnoozeHint ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showSnoozeHint)
                    .onAppear { showSnoozeHint = true }
                }

                if alarm.snoozeStyle == .button && !isUltimatum {
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
                }
            }
            .padding()
            .offset(y: alarm.snoozeStyle == .swipe ? -dragOffset : 0)
            .gesture(
                alarm.snoozeStyle == .swipe && !isUltimatum ?
                DragGesture()
                    .onChanged { value in
                        if value.translation.height < 0 {
                            dragOffset = -value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height < -snoozeThreshold {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                            alarmManager.snoozeAlarm()
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    } : nil
            )
        }
    }

    private func submitAnswer() {
        guard let answer = Int(userAnswer) else {
            showError = true
            return
        }
        let correct = alarmManager.checkMathAnswer(answer)
        if correct {
            userAnswer = ""
            showError = false
        } else {
            showError = true
            userAnswer = ""
        }
    }
}
