//
//  ViewController.swift
//  Trivia
//
//  Created by Kevin Ibarra Rivas on 2/21/26.
//

import UIKit

// MARK: - Data Models

struct TriviaQuestion: Decodable {
    let category: String
    let question: String        // the prompt
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case question
        case correctAnswer   = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

// MARK: - HTML Entity Decoding Helper

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        else { return self }
        return attributed.string
    }
}

// MARK: - Service

// Separate class that owns all the networking/parsing logic
class TriviaQuestionService {
    func fetchQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10"
        guard let url = URL(string: urlString) else {
            completion(nil); return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                var decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
                // Decode HTML entities in every question and answer
                decoded = TriviaResponse(results: decoded.results.map { q in
                    TriviaQuestion(
                        category: q.category.htmlDecoded,
                        question: q.question.htmlDecoded,
                        correctAnswer: q.correctAnswer.htmlDecoded,
                        incorrectAnswers: q.incorrectAnswers.map { $0.htmlDecoded }
                    )
                })
                DispatchQueue.main.async { completion(decoded.results) }
            } catch {
                print("❌ Decode error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}

// MARK: - View Controller

class ViewController: UIViewController {

    // Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionCounterLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    // Data
    private let questionService = TriviaQuestionService()
    private var questions = [TriviaQuestion]()


    private var currentAnswers = [String]()
    private var correctAnswerIndex = -1

    private var currentIndex = 0
    private var score = 0

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
        fetchQuestions()   //REAL API
    }

    // MARK: - Networking

    private func fetchQuestions() {
        // Show loading state while we wait for the network
        questionLabel.text = "Loading questions…"
        questionCounterLabel.text = ""
        setButtonsEnabled(false)

        questionService.fetchQuestions { [weak self] fetched in
            guard let self = self else { return }
            if let fetched = fetched, !fetched.isEmpty {
                self.questions = fetched
                self.currentIndex = 0
                self.score = 0
                self.loadQuestion()
            } else {
                self.showNetworkError()
            }
        }
    }

    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Couldn't Load Questions",
            message: "Check your internet connection and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.fetchQuestions()
        })
        present(alert, animated: true)
    }

    // MARK: - UI Setup

    func styleButtons() {
        for button in [button1, button2, button3, button4] {
            guard let btn = button else { continue }
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = UIColor.systemBlue.cgColor
            btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
        }
    }

    func loadQuestion() {
        guard currentIndex < questions.count else {
            showResults()
            return
        }

        let q = questions[currentIndex]
        questionLabel.numberOfLines = 0
        questionLabel.text = q.question
        questionCounterLabel.text = "Question \(currentIndex + 1) of \(questions.count)"

        currentAnswers = ([q.correctAnswer] + q.incorrectAnswers).shuffled()
        correctAnswerIndex = currentAnswers.firstIndex(of: q.correctAnswer) ?? 0

        let buttons = [button1, button2, button3, button4]

        
        buttons.forEach {
            $0?.isHidden = true
            $0?.isEnabled = true
            $0?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        }
        for (i, answer) in currentAnswers.enumerated() {
            buttons[i]?.setTitle(answer, for: .normal)
            buttons[i]?.isHidden = false
        }
    }

    // MARK: - Actions

    @IBAction func answerTapped(_ sender: UIButton) {
        let buttons = [button1, button2, button3, button4]
        setButtonsEnabled(false)

        let tappedIndex = buttons.firstIndex(of: sender) ?? -1

        if tappedIndex == correctAnswerIndex {
            score += 1
            sender.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
        } else {
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.4)
            // COLOR FOR RIGHT AND WRONG
            buttons[correctAnswerIndex]?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
        }

        //FEEDBACK PAUSE
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.currentIndex += 1
            self.loadQuestion()
        }
    }

    func showResults() {
        let alert = UIAlertController(
            title: "Quiz Complete!",
            message: "You got \(score) out of \(questions.count) correct.",
            preferredStyle: .alert
        )
        // PLAY AGAIN
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { _ in
            self.fetchQuestions()
        })
        present(alert, animated: true)
    }

    // MARK: - Helpers

    private func setButtonsEnabled(_ enabled: Bool) {
        [button1, button2, button3, button4].forEach { $0?.isEnabled = enabled }
    }
}
