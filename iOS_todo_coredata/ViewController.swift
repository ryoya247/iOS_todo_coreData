import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    
    var todos:[Todo] = []
//    var todosToShow:[String:[[String]]] = ["Todo":[[]], "Task":[[]]]
//    var todoCategories:[String] = ["Todo","Task"]
    var todosToShow = [String:[[String]]]()
    var todoCategories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.userDefaults.object(forKey: "todoCategories") != nil {
            self.todoCategories = self.userDefaults.stringArray(forKey: "todoCategories")!
            for i in 0..<todoCategories.count {
                self.todosToShow[todoCategories[i]] = [[]]
            }
        } else {
            self.todoCategories = ["Todo","Task","その他"]
            self.todosToShow = ["Todo":[[]], "Task":[[]], "その他": [[]]]
            userDefaults.set(todoCategories, forKey: "todoCategories")
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            todos = try context.fetch(fetchRequest)
            print(todos)
            
            // 配列を空にする。（同じデータを複数表示しないため）
            for key in todosToShow.keys {
                todosToShow[key] = []
            }
            // fetchしたデータを配列に格納する
            for todo in todos {
                print(todo.category!)
                todosToShow[todo.category!]?.append([todo.content!, todo.dueDate!])
            }
        } catch {
            print("Fetching Failed.")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.todoCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return todoCategories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todosToShow[todoCategories[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell",for: indexPath) as! CustomTableViewCell
        
        let sectionData = self.todosToShow[todoCategories[indexPath.section]]
        print(sectionData ?? "")
        let cellData = sectionData?[indexPath.row]
        print(cellData ?? "")
        
        
        cell.titleLabel?.text = cellData?[0]
        cell.dueDateLabel?.text = cellData?[1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let deletedCategory = todoCategories[indexPath.section]
            let deletedContent = todosToShow[deletedCategory]?[indexPath.row][0]
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "content = %@ and category = %@", deletedContent!, deletedCategory)
            do {
                let task = try context.fetch(fetchRequest)
                context.delete(task[0])
            } catch {
                print("Fetching Failed.")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            getData()
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "editTodo" {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let VC = segue.destination as! AddTodoViewController
            VC.context = context
            let indexPath = self.tableView.indexPathForSelectedRow
            let editCategory = todoCategories[(indexPath?.section)!]
            let editContent = todosToShow[editCategory]?[(indexPath?.row)!][0]
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "content = %@ and category = %@", editContent!, editCategory)
            do {
                let todo = try context.fetch(fetchRequest)
                VC.todo = todo[0]
            } catch {
                print("Fetching Failed.")
            }
        }
        
    }


}

