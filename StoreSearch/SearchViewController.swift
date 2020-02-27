//
//  ViewController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 2/26/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import UIKit




class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchBarResults: [SearchResult] = []
    var hasSearch: Bool = false
    
    // for constant identifier of searchResultCell in this SearchViewController file
    struct TableView {
        struct CellIdentifier {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // load UI via .xib or .nib file
        var cellNib = UINib(nibName: TableView.CellIdentifier.searchResultCell, bundle: nil)
        
        // register cellNib into tableView via identifer of that cell
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifier.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifier.nothingFoundCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifier.nothingFoundCell)
        
        
        // setting delegate via code or storyboard Ctrl + drag into delegate
        self.searchBar.delegate = self // for searchBarDelegate
        self.tableView.delegate = self // for tableViewDelegate
        self.tableView.dataSource = self // for tableViewDataSource
        
        print("Loaded")
        
        // top margin -> 20 for status, 44 for search bar
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }


}

// listening the action of UISearchBar via extension
extension SearchViewController: UISearchBarDelegate {
        
    
    // when the search bar button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search Bar Button is clicked \(searchBar.text!)")
        hasSearch = true
        
        // add fake data
        searchBarResults = []
        if searchBar.text! != "abc" {
            for i in 0...2 {
                // format: text
                // i: index - locations => %d
                // searchBar.text! - argument that could be encoded => %@ any kind of type
                let newSearchResult = SearchResult()
                newSearchResult.name = String(format: "Fake Results %d for", i)
                newSearchResult.artistName = searchBar.text!
                searchBarResults.append(newSearchResult)
            }
        }
        // reload table view cell data after editing data from a list
        tableView.reloadData()
        
        // hiding keyboard after clicking Search button
        searchBar.resignFirstResponder() // becomeFirstResponder() >< resignFirstResponder()
        
        // we could hide the keyboard if we click tableView depending on gesture on it
        // tableView's Attribute -> keyboard -> dismiss interactively
    }
    
    
    // setting topView of searchBar
    // delegate for UINavigationBar and UISearchBar -> .top is default
    // UIToolBar -> UIBarPosition.bottom is default
    // .top is the top of its containing View
    // .topAttach is the top of the screen, as well as the containing View
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // set the top of the screen
    }
}

// listening the action of UITableView via UITableViewDelegate
// and managing data and provide cells for table view
// we need to hook up the UITableViewDataSource in this situation because of using normal UITableView not UITableViewController
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // number of rows in a section in a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearch {
            return 0
        } else if searchBarResults.count == 0 {
            return 1
        } else {
            return searchBarResults.count
        }
    }
    
    // customize cells for each row
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // this must be the same name of NibCellIdentifer in this case
//        let cellIdentifier = "CellIdentifier"
//        let cellIdentifier = "SearchResultCell"
        
        // tableView.dequeueReusableCell(withIdentifier:) return UITableViewCell? (optional) -> cell: UITableViewCell!
        // tableView.dequeueReusaboecell(withIdentifier:for) return UITableViewCell (not optional) -> cell: UITableViewCell => this only work if we register a nib file or using a prototype cell
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.searchResultCell, for: indexPath) as! SearchResultCell // this will be added into indexPath -> not nil
        
        
        
        // because of using nib design file, we dont need to create the default one
        /*
        // if the cell is empty -> create a new one
        if cell == nil {
            // title and subtitle cell
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        */
        
        // because we use the custom cell (from nib) => do not use textLabel and detailTextLabel which is from UITableViewCell
        if searchBarResults.count == 0 {
//            cell.textLabel!.text = "(Nothing found)"
//            cell.detailTextLabel!.text = ""
            // for NothingFoundCell.xib
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.searchResultCell, for: indexPath) as! SearchResultCell // this will be added into indexPath -> not nil
            
            // cell.textLabel return an optional -> unwrap it
            // extract text (String) from textLabel
            let searchResult = searchBarResults[indexPath.row]
            cell.nameLabel.text = searchResult.name // for title
            cell.artistNameLabel.text = searchResult.artistName // for subtitle
            return cell
        }
    }
    
    // handling selection of row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // de-select row after selecting that row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // customization cell before selecting
    // in this case, nothing found isn't selected
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchBarResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}
