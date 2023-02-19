//
//  ViewController.swift
//  Fullers memory list
//
//  Created by Ihor Dolhalov on 05.02.2023.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {


    private var fetchedResultsController = StorageManager.shared.getFetchedResultsController(
        entityName: "Task",
        keysForSort: ["isComplete", "date"]
    )

    
    
    private func fetchTasks() {
         do {
             try fetchedResultsController.performFetch()
         } catch {
             print(error)
         }
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTasks()
        fetchedResultsController.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    private func setupNavigationBar() {
           title = "Task List" // 1
           let fontName = "Apple SD Gothic Neo Bold" // 2
           navigationController?.navigationBar.prefersLargeTitles = true // 3
           
           let navBarAppearance = UINavigationBarAppearance() // 4
           navBarAppearance.configureWithOpaqueBackground() // 5
          
           navBarAppearance.titleTextAttributes = [ // 6
               .font: UIFont(name: fontName, size: 19) ?? UIFont.systemFont(ofSize: 19),
               .foregroundColor: UIColor.white
           ]
           navBarAppearance.largeTitleTextAttributes = [ // 7
               .font: UIFont(name: fontName, size: 35) ?? UIFont.systemFont(ofSize: 35),
               .foregroundColor: UIColor.white
           ]
           navBarAppearance.backgroundColor = UIColor( // 8
               red: 97/255,
               green: 210/255,
               blue: 255/255,
               alpha: 255/255
           )

           navigationController?.navigationBar.standardAppearance = navBarAppearance // 9
           navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance // 10
       }

    private func setContentForCell(with task: Task?) -> UIListContentConfiguration {
           var content = UIListContentConfiguration.cell()
           
           content.textProperties.font = UIFont(
               name: "Avenir Next Medium", size: 23
           ) ?? UIFont.systemFont(ofSize: 23)
           
        content.textProperties.color = .darkGray
        content.text = task?.title
        content.attributedText = strikeThrough(string: task?.title ?? "", task?.isComplete ?? false)
        
           return content
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // 1
            tableView.deselectRow(at: indexPath, animated: true) // 2
            let task = fetchedResultsController.object(at: indexPath) as? Task // 3
            performSegue(withIdentifier: "editTask", sender: task) // 4
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editTask" { // 1
                guard let newTaskVC = segue.destination as? NewTaskViewController else { return } // 2
                newTaskVC.task = sender as? Task // 3
            }
        }
    
    private func strikeThrough(string: String, _ isStrikeThrough: Bool) -> NSAttributedString {
            isStrikeThrough
                ? NSAttributedString(
                    string: string,
                    attributes: [
                        NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.double.rawValue
                    ]
                )
                : NSAttributedString(
                    string: string,
                    attributes: [NSAttributedString.Key.strikethroughStyle : 0]
                )
        }
    
    
    
    
    
}

// MARK: - Table View Delegate



extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in // 1
            if let task = self.fetchedResultsController.object(at: indexPath) as? Task {
                StorageManager.shared.done(task: task)
            }
            isDone(true) // 2
        }
        doneAction.image = UIImage(systemName: "checkmark") // 3
        doneAction.backgroundColor  = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in // 1
            if let task = self.fetchedResultsController.object(at: indexPath) as? Task { // 2
                StorageManager.shared.delete(task: task) // 3
            }
        }
        
        deleteAction.image = UIImage(systemName: "trash") // 4
        
        return UISwipeActionsConfiguration(actions: [deleteAction]) // 5
    }
}


    // MARK: - Table View Data Soutce

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()
            let task = fetchedResultsController.object(at: indexPath) as? Task
            cell.contentConfiguration = setContentForCell(with: task)
            return cell
        }
}

// MARK: - NSFetchResultsControllerDelegate
extension TaskListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { // 1
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {  // 2
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let cell = tableView.cellForRow(at: indexPath)
            let task = getTask(at: newIndexPath) // 1
            cell?.contentConfiguration = setContentForCell(with: task) // 2
            tableView.moveRow(at: indexPath, to: newIndexPath) // 3
        default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { // 3
        tableView.endUpdates()
    }
    
    private func getTask(at indexPath: IndexPath?) -> Task? {
            if let indexPath = indexPath {
                return fetchedResultsController.object(at: indexPath) as? Task
            }
            return nil
        }
}
