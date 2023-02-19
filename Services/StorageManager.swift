//
//  StorageManager.swift
//  Fullers memory list
//
//  Created by Ihor Dolhalov on 12.02.2023.
//
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FullersMemoryList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    
    func getFetchedResultsController(entityName: String, keysForSort: [String]) -> NSFetchedResultsController<NSFetchRequestResult> { // 1
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName) // 2
        var sortDescriptors: [NSSortDescriptor] = [] // 2
        keysForSort.forEach { keyForSort in // 3
                let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
                sortDescriptors.append(sortDescriptor)
            }
            fetchRequest.sortDescriptors = sortDescriptors
            
            let fetchResultsController = NSFetchedResultsController( // 5
                fetchRequest: fetchRequest,
                managedObjectContext: viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            return fetchResultsController // 6
        }
    
    func edit(task: Task, with newTitle: String) {
            task.title = newTitle
            saveContext()
        }
    
    func saveTask(withTitle title: String) {
            let task = Task(context: viewContext) // 1
            task.title = title
            task.date = Date()
        task.isComplete = false // 1
            saveContext() // 2
        }
    
    func done(task: Task) {
        task.isComplete.toggle()
        saveContext()
    }
    
    func delete(task: Task) {
            viewContext.delete(task)
            saveContext()
        }
    
    
    
    // MARK: - Core Data Saving support
        func saveContext() {
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    
}
