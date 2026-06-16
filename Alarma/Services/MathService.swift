import Foundation

final class MathService {
    static let shared = MathService()

    private init() {}

    func generateProblem(difficulty: MathDifficulty = .medium) -> MathProblem {
        MathProblem.generate(difficulty: difficulty)
    }

    func checkAnswer(_ problem: MathProblem, userAnswer: Int) -> Bool {
        problem.answer == userAnswer
    }
}
