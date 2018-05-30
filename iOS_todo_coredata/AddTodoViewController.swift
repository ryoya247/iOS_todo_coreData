//
//  AddTodoViewController.swift
//  iOS_todo_coredata
//
//  Created by 井野稜也 on 2018/05/29.
//  Copyright © 2018年 ryoya.ino. All rights reserved.
//

import UIKit

class AddTodoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    let datePicker = UIDatePicker()
    let categoryPicker = UIPickerView()
    var categories = [String]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todo: Todo?

    
    @IBAction func taskTextFieldChanged(_ sender: Any) {
        self.updateSaveButtonState()
    }
    @IBAction func dueDateTextFieldChanged(_ sender: Any) {
        self.updateSaveButtonState()
    }
    @IBAction func categoryTextFieldChanged(_ sender: Any) {
        self.updateSaveButtonState()
    }
    private func updateSaveButtonState() {
        let task = self.taskTextField.text ?? ""
        let dueDate = self.dueDateTextField.text ?? ""
        let category = self.categoryTextField.text ?? ""
        self.saveButton.isEnabled = !task.isEmpty && !dueDate.isEmpty && !category.isEmpty
    }
    
    // picker作成
    private func createPicker () {
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedForPicker))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressedForPicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.sizeToFit()
        toolBar.items = [cancelButton,flexibleSpace,doneButton]
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        categoryTextField.inputAccessoryView = toolBar
        categoryTextField.inputView = categoryPicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        return self.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return self.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        self.categoryTextField.text = self.categories[row]
    }
    
    // datePicker作成
    private func createDatePicker() {
        
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.sizeToFit()
        toolBar.items = [cancelButton,flexibleSpace,doneButton]
        
        dueDateTextField.inputAccessoryView = toolBar
        dueDateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        
    }
    
    // pickerの完了ボタン
    @objc func donePressedForPicker () {
        self.view.endEditing(true)
    }
    // pickerのキャンセルボタン
    @objc func cancelPressedForPicker () {
        self.categoryTextField.text = ""
        self.view.endEditing(true)
    }
    // datePickerの完了ボタン
    @objc func donePressed () {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        dueDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    // datePickerのキャンセルボタン
    @objc func cancelPressed () {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let todo = todo {
            self.taskTextField.text = todo.content
            self.categoryTextField.text = todo.category
            self.dueDateTextField.text = todo.dueDate
            self.navigationItem.title = "タスク編集"
        }
        self.categories = UserDefaults.standard.object(forKey: "todoCategories") as! [String]
        print(self.categories)
        self.createPicker()
        self.createDatePicker()
        self.updateSaveButtonState()

    }
    
    // navbarのcancelボタン押下
    @IBAction func onCancel(_ sender: Any) {
        if self.presentingViewController is UINavigationController {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // navbarのsaveボタン押下
    @IBAction func onSave(_ sender: Any) {
        let taskText = self.taskTextField.text
        let dueDate = self.dueDateTextField.text
        let category = self.categoryTextField.text
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if todo == nil {
            todo = Todo(context: context)
        }
        
        if let todo = todo {
            todo.content = taskText
            todo.dueDate = dueDate
            todo.category = category
            print(todo)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        if self.presentingViewController is UINavigationController {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
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
