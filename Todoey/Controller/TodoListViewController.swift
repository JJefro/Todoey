//
//  ViewController.swift
//  Todoey
//
//  Created by Jevgenijs Jefrosinins on 18/04/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    
    var toDoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
        
        loadItems()
        
        //        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
        //            itemArray = items
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let colorHex = selectedCategory?.backgroundColor {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            
            if let navBarColour = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColour
               
                view.backgroundColor = navBarColour
                
                searchBar.barTintColor = navBarColour.lighten(byPercentage: CGFloat(4) / CGFloat(10))
            
                
                if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                    textfield.backgroundColor = UIColor.white
                    textfield.textColor = UIColor.black
                }
                
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
        // ? - Optional Chaining. If hexString in not nil - we darken
            if let colour = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                
            }
        } else {
            cell.textLabel?.text = "No Item Added Yet"
        }
        // Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        //                if item.done == true {
        //                    cell.accessoryType = .checkmark
        //                } else {
        //                    cell.accessoryType = .none
        //                }
        return cell
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    //                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error with saving done status, \(error)")
            }
        }
        tableView.reloadData()
        //                     False or  True
        //        toDoItems[indexPath.row].done = !toDoItems[indexPath.row].done
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //        saveItems()
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] (action) in
            //what will happen once the user clicks the Add Item on our Alert
            if let currentCategory = selectedCategory {
                do {
                    try realm.write {
                        let newItem = Item()
                        let newItemText = textField.text!
                        if newItemText != ""  {
                            newItem.title = newItemText
                            newItem.dateCreated = Date()
                            print(newItem.dateCreated!)
                        }
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error with saving new items, \(error)")
                }
            }
            tableView.reloadData()
            //            if let currentCategory = selectedCategory {
            //                let newItem = Item()
            //                let newItemText = textField.text!
            //
            //                if newItemText != ""  {
            //                    newItem.title = newItemText
            //                }
            //                currentCategory.items.append(newItem)
            //                save(items: newItem)
            //            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulating Methods
    
    func save(items: Item) {
        do {
            try realm.write {
                realm.add(items)
            }
        } catch {
            print("Error saving realm object of items \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        //sorted by alphabetical order
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error with deleting item, \(error)")
            }
            tableView.reloadData()
        }
    }
}
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
////        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//


//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//
//        request.predicate = compoundPredicate
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//    }


//MARK: - SearchBar Methods


extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    // It's the same, that in Cora Data like this -
    //            let request : NSFetchRequest<Item> = Item.fetchRequest()
    
    //            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    //
    //            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    //
    //            loadItems(with : request, predicate: predicate)
    //        do {
    //            itemArray = try context.fetch(request)
    //        } catch {
    //            print("Error fetching data from context \(error)")
    //        }
    //            tableView.reloadData()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

