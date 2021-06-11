//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jevgenijs Jefrosinins on 24/04/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // Add possibility Create, Read, Update and Destroy Data (CRUD)
    let realm = try! Realm()
    // New collection type which is a collection of results that our Category objects. And this is an optional, so that we can be safe.
    var categoryArray : Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //And when our view first gets loaded up, we load up all of the categories that we currently own.
        loadCategory()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        if let navBarColour = UIColor(hexString: "ffe9d6") {
            
            navBar.backgroundColor = navBarColour
            
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
            
            view.backgroundColor = navBarColour
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If category is nil it returns 1 Number of Rows in Section
        //the number of categories as the number of rows.
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let category = categoryArray?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.backgroundColor) else {fatalError()}
             
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            
        } else {
            cell.textLabel?.text = "No Categories Added Yet"
            cell.backgroundColor = UIColor(hexString: "2589E6")
        }
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving realm object of category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory() {
        //So inside loadCategory, we set that property categories to look inside our realm and fetch all of the objects that belong to the Category data type.
        categoryArray = realm.objects(Category.self)
        
        //And then we reload our tableView with the new data.
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //        handle action by updating model with deletion
        if let categoryForDeletion = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add New Category", style: .default) { [self] (action) in
            //what will happen once the user clicks the Add Item on our Alert
            let newCategory = Category()
            
            let randomColorString = UIColor.randomFlat().hexValue()
            
            let newCategoryText = textField.text!
            
            if newCategoryText != "" {
                newCategory.name = newCategoryText
                newCategory.backgroundColor = randomColorString
            }
            save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


