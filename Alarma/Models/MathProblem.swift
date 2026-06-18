import Foundation

struct MathProblem {
    let question: String
    let answer: Int

    static func generate(difficulty: MathDifficulty) -> MathProblem {
        let maxNum = difficulty.level * 10
        let operations: [String] = difficulty.level <= 2 ? ["+", "-"] : ["+", "-", "*"]
        let op = operations.randomElement()!
        let a: Int
        let b: Int

        switch op {
        case "+":
            a = Int.random(in: 1...maxNum)
            b = Int.random(in: 1...maxNum)
            return MathProblem(question: "\(a) + \(b) = ?", answer: a + b)
        case "-":
            a = Int.random(in: 1...maxNum)
            b = Int.random(in: 1...a)
            return MathProblem(question: "\(a) - \(b) = ?", answer: a - b)
        case "*":
            a = Int.random(in: 1...(difficulty.level * 5))
            b = Int.random(in: 1...(difficulty.level * 3))
            return MathProblem(question: "\(a) x \(b) = ?", answer: a * b)
        default:
            a = Int.random(in: 1...maxNum)
            b = Int.random(in: 1...maxNum)
            return MathProblem(question: "\(a) + \(b) = ?", answer: a + b)
        }
    }
}
