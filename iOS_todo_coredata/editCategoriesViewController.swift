//
//  editCategoriesViewController.swift
//  iOS_todo_coredata
//
//  Created by 井野稜也 on 2018/05/31.
//  Copyright © 2018年 ryoya.ino. All rights reserved.
//

import UIKit
import CoreData

class editCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
  
    var categories = [String]()
    var flag = false

    @IBOutlet weak var categoryTable: UITableView!
    @IBOutlet weak var addCategoryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryTextField.delegate = self
        categoryTable.delegate = self
        categoryTable.dataSource = self
        self.categories = UserDefaults.standard.object(forKey: "todoCategories") as! [String]
        self.navigationItem.title = "カテゴリ編集"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTable.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = self.categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let targetCategory = categories[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category = %@",targetCategory)
            do {
                let task = try context.fetch(fetchRequest)
                if (task.count > 0) {
                    let alertController:UIAlertController = UIAlertController(title: "確認", message: "このカテゴリにあるアイテムは全て消去されます。よろしいですか？", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default){
                        action in
                        for i in 0..<task.count {
                            context.delete(task[i])
                        }
                        self.categories.remove(at: indexPath.row)
                        UserDefaults.standard.set(self.categories, forKey: "todoCategories")
                        let confirm:UIAlertController = UIAlertController(title: "お知らせ", message: "消去しました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default){
                            action in
                        }
                        confirm.addAction(ok)
                        self.present(confirm, animated: true, completion: nil)
                        self.categoryTable.reloadData()
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .default){
                        action in
                    }
                    alertController.addAction(okAction)
                    alertController.addAction(cancel)
                    present(alertController, animated: true, completion: nil)
                } else {
                    self.categories.remove(at: indexPath.row)
                    UserDefaults.standard.set(self.categories, forKey: "todoCategories")
                }
            } catch {
                print("Fetching Failed.")
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        categoryTable.reloadData()
    }
    // navbarのキャンセル押下
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 追加ボタン
    @IBAction func onAddButton(_ sender: Any) {
        if (!(self.addCategoryTextField.text?.isEmpty)!) {
            if (categories.count == 0) {
                self.categories.append(self.addCategoryTextField.text!)
                UserDefaults.standard.set(self.categories, forKey: "todoCategories")
                categoryRegistAlert()
                self.addCategoryTextField.text = ""
                categoryTable.reloadData()
            } else if (categories.count > 0) {
                for i in categories {
                    if (self.addCategoryTextField.text == i) {
                        self.flag = true
                        let alertController:UIAlertController = UIAlertController(title: "確認", message: "既に存在するカテゴリです", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default){
                            action in
                        }
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
                        self.addCategoryTextField.text = ""
                        break;
                    }
                }
                if (!self.flag) {
                    self.categories.append(self.addCategoryTextField.text!)
                    UserDefaults.standard.set(self.categories, forKey: "todoCategories")
                    categoryRegistAlert()
                    self.addCategoryTextField.text = ""
                    categoryTable.reloadData()
                }
            }
        } else {
            let alertController:UIAlertController = UIAlertController(title: "確認", message: "カテゴリを入力してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default){
                action in
                print("ok")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func categoryRegistAlert () {
        let alertController:UIAlertController = UIAlertController(title: "お知らせ", message: "カテゴリを追加しました", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){
            action in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCategoryTextField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
