//
//  ViewController.swift
//  Trivia
//
//  Created by Kevin Ibarra Rivas on 2/21/26.
//

import UIKit
struct TriviaQuestion {
    let prompt: String
    let choices: [String]
    let correctIndex: Int
}

class ViewController: UIViewController {

    //Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionCounterLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    // Data
    let questions: [TriviaQuestion] = [
        TriviaQuestion(
            prompt: "What is the capital of France?",
            choices: ["Berlin", "Madrid", "Paris", "Rome"],
            correctIndex: 2
        ),
        TriviaQuestion(
            prompt: "Which planet is closest to the sun?",
            choices: ["Venus", "Mercury", "Earth", "Mars"],
            correctIndex: 1
        ),
        TriviaQuestion(
            prompt: "How many sides does a hexagon have?",
            choices: ["5", "7", "8", "6"],
            correctIndex: 3
        ),
        TriviaQuestion(
            prompt: "What is the largest ocean on Earth?",
            choices: ["Atlantic", "Indian", "Arctic", "Pacific"],
            correctIndex: 3
        ),
        TriviaQuestion(
            prompt: "Who wrote 'Romeo and Juliet'?",
            choices: ["Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"],
            correctIndex: 1
        )
    ]

    var currentIndex = 0
    var score = 0

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
        loadQuestion()
    }

    //UI Setup
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
        questionLabel.text = q.prompt
        questionCounterLabel.text = "Question \(currentIndex + 1) of \(questions.count)"

        let buttons = [button1, button2, button3, button4]
        for (i, btn) in buttons.enumerated() {
            btn?.setTitle(q.choices[i], for: .normal)
            btn?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
            btn?.isEnabled = true
        }
    }

    //Actions
    @IBAction func answerTapped(_ sender: UIButton) {
        let q = questions[currentIndex]
        let buttons = [button1, button2, button3, button4]

        // Disable all buttons so user can't tap again
        buttons.forEach { $0?.isEnabled = false }

        // Figure out which button was tapped
        let tappedIndex = buttons.firstIndex(of: sender) ?? -1

        if tappedIndex == q.correctIndex {
            score += 1
            sender.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
        } else {
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.4)
            // Also highlight the correct answer
            buttons[q.correctIndex]?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
        }

        // Wait a moment, then move to the next question
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
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.currentIndex = 0
            self.score = 0
            self.loadQuestion()
        }))
        present(alert, animated: true)
    }
}
