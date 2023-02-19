//
//  NewTaskViewController.swift
//  Fullers memory list
//
//  Created by Ihor Dolhalov on 05.02.2023.
//

import UIKit

class NewTaskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //doneButton.isHidden = true
        setupTextView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
      
    }
    var task: Task?
    @IBOutlet var taskTextView: UITextView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var cancelButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        guard let title = taskTextView.text, !title.isEmpty else { return }
               
               if let task = task { // 1
                   StorageManager.shared.edit(task: task, with: title)
               } else { // 2
                   StorageManager.shared.saveTask(withTitle: title)
               }
               dismiss(animated: true)
           }
    
    
    private func setupTextView() {
        taskTextView.becomeFirstResponder()
                if let task = task {
                    taskTextView.text = task.title
                } else {
                    doneButton.isHidden = true
                }
    }
    
}



// MARK: - Text view delegate
extension NewTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden { // 1
            textView.text.removeAll() // 2
            doneButton.isHidden = false // 3
            
            UIView.animate(withDuration: 0.3) { // 4
                self.view.layoutIfNeeded() // 5
            }
        }
    }
}

// MARK: - Keyboard
extension NewTaskViewController {
    @objc private func keyboardWillShow(with notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        bottomConstraint.constant = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
