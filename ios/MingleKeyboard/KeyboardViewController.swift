import UIKit

final class KeyboardViewController: UIInputViewController {
    private let draft = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.99, alpha: 1)
        view.heightAnchor.constraint(equalToConstant: 230).isActive = true

        let title = UILabel()
        title.text = "mingle  ·  your words, your way"
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.textColor = UIColor(red: 0.13, green: 0.10, blue: 0.19, alpha: 1)

        let nextKeyboard = UIButton(type: .system)
        nextKeyboard.setTitle("🌐", for: .normal)
        nextKeyboard.accessibilityLabel = "Next keyboard"
        nextKeyboard.addTarget(
            self,
            action: #selector(advanceToNextInputMode),
            for: .touchUpInside
        )
        let header = UIStackView(arrangedSubviews: [title, nextKeyboard])
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .equalSpacing

        draft.font = .systemFont(ofSize: 15)
        draft.backgroundColor = .white
        draft.layer.cornerRadius = 12
        draft.text = "Write a reply to insert"

        let insert = UIButton(type: .system)
        insert.setTitle("Insert reply", for: .normal)
        insert.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        insert.backgroundColor = UIColor(red: 0.35, green: 0.21, blue: 0.71, alpha: 1)
        insert.tintColor = .white
        insert.layer.cornerRadius = 12
        insert.addTarget(self, action: #selector(insertDraft), for: .touchUpInside)

        let privacy = UILabel()
        privacy.text = "This keyboard does not read surrounding text. Type and review before inserting."
        privacy.font = .systemFont(ofSize: 11)
        privacy.textColor = .secondaryLabel
        privacy.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [header, draft, insert, privacy])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            draft.heightAnchor.constraint(equalToConstant: 70),
            insert.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func insertDraft() {
        let text = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text != "Write a reply to insert" else { return }
        textDocumentProxy.insertText(text)
    }
}
