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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
    var searchBarResults: [SearchResult] = []
    var hasSearch: Bool = false
    var isLoading: Bool = false
    var dataTask: URLSessionDataTask?
    
    // for constant identifier of searchResultCell in this SearchViewController file
    struct TableView {
        struct CellIdentifier {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
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
        
        cellNib = UINib(nibName: TableView.CellIdentifier.loadingCell, bundle: nil)
        
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifier.loadingCell)
        
        
        // setting delegate via code or storyboard Ctrl + drag into delegate
        self.searchBar.delegate = self // for searchBarDelegate
        self.tableView.delegate = self // for tableViewDelegate
        self.tableView.dataSource = self // for tableViewDataSource
        self.tableView.rowHeight = 80
        
        print("Loaded")
        
        // top margin -> 20 for status, 44 for search bar, 44 for navigation bar
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
    
        searchBar.becomeFirstResponder()
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        
        segmentedControl.selectedSegmentTintColor = segmentColor
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    


}

// listening the action of UISearchBar via extension
extension SearchViewController: UISearchBarDelegate {
    
    // this func is from UISearchBarDelelgate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    
    // when the search bar button is clicked
    func performSearch() {
        
        if !searchBar.text!.isEmpty {
            print("Search Bar Button is clicked \(searchBar.text!)")
            

             // hiding keyboard after clicking Search button
             searchBar.resignFirstResponder() // becomeFirstResponder() >< resignFirstResponder()
            
             // we could hide the keyboard if we click tableView depending on gesture on it
             // tableView's Attribute -> keyboard -> dismiss interactively
            
            dataTask?.cancel()
            hasSearch = true
            isLoading = true
            tableView.reloadData()
            
            
            // add fake data
            searchBarResults = []
           
            /* // for FAKE DATAs
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
    
            */
           
            
//            // ==================================== Networking stuff
//            let queue = DispatchQueue.global() // reference to a (global) queue - we could create our own one
//
//            // return the URL from the String
//            let url = iTunesURL(searchText: searchBar.text!)
//            print("URL: \(url)")
//
//            // ALL OF UI METHODS MUST BE OUTSIDE OF ASYNC TASKS
//            // MOVE TO MAIN THREADS
//            // return the @escaping Void type
//            queue.async {
//                // perform fetching from the current URL
//                if let data = self.performStoreRequest(with: url) {
//    //                print("Received JSON string: '\(jsonString)'")
//    //                let results = parse(data: data)
//                    self.searchBarResults = self.parse(data: data)
//    //                print("Got results: \(results)")
//                    self.searchBarResults.sort() {
//                        result1, result2 in
//                        return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
//                    }
//
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//                        self.tableView.reloadData()
//                    }
//                    return
//
//                }
//            }
//           // ===================================== End of Networking Stuff
            
            
            // Networking stuff v.2 with URLSesssion
            // URLSession has a nice feature - Cancel the request
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url) {
                [weak self] data, response, error in
                
                if let error = error as NSError?, error.code == -999 {
                    return
                } else if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
//                    print("Success! \(data!)")
                    if let data = data, let weakSelf = self {
                        weakSelf.searchBarResults = weakSelf.parse(data: data)
                        weakSelf.searchBarResults.sort() {
                            $0.name.localizedStandardCompare($1.name) == .orderedAscending
                        }
                        // update UI
                        DispatchQueue.main.async {
                            weakSelf.isLoading = false
                            weakSelf.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                
                if let weakSelf = self {
                    DispatchQueue.main.async {
                        weakSelf.hasSearch = false
                        weakSelf.isLoading = false
                        weakSelf.tableView.reloadData()
                        weakSelf.showNetworkError()
                    }
                }
                
            }
            dataTask?.resume() // to start the dataTask -> this sends the request to the server on a background thread -> the application is free to use immediately
            
            
            
            // reload table view cell data AFTER editing data from a list
            
           /* Working with GCD
             let queue = DispatchedQueue.global()
             queue.async {
                // code that needs to run in background
             
                DispatchedQueue.main.async {
                    // update the user interface
                }
             }
             
             */

        }
        
    }
    
    
    // setting topView of searchBar
    // delegate for UINavigationBar and UISearchBar -> .top is default
    // UIToolBar -> UIBarPosition.bottom is default
    // .top is the top of its containing View
    // .topAttach is the top of the screen, as well as the containing View
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // set the top of the screen
    }
    
    
    // MARK: - Helper Methods for UISearchBarDelegate
    func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
            case 1: kind = "musicTrack"
            case 2: kind = "software"
            case 3: kind = "ebook"
            default: kind = ""
        }
        
        
        // searchText may have space, so we need to encode it
        // String.addingPercentEncoding - replacing existing text into allowed specific text
        // CharacterSet.urlQueryAllowed - the character set of characters allowed in query component
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print(encodedText)
         // for API string
         // term=
         //
         let urlString = String(format: "https://itunes.apple.com/search?" +
            "term=%@&limit=200&entity=\(kind)", encodedText)
         print(urlString)
         let url = URL(string: urlString) // location for local file or remote server
         
         return url!
     }

    
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            // decode the returned data from server into ResultArray form which is conformed Codable
            let result = try decoder.decode(ResultArray.self, from: data)
            
            // as you can see, this ResultArray works like a temporary class for decoding
            // results property in this class
            return result.results
        } catch {
            print("JSON error \(error)")
            return []
        }
    }
    
    // MARK: - Handing Error
    
    // this method handle network error
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
                                      message: "There was an error accessing the iTunes Store. " +
                                                " Please try again.",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil)
    
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// listening the action of UITableView via UITableViewDelegate
// and managing data and provide cells for table view
// we need to hook up the UITableViewDataSource in this situation because of using normal UITableView not UITableViewController
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // number of rows in a section in a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading{
            return 1
        } else if !hasSearch {
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

        /*
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
        */
        
        // for showing indication view activity
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
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
               
                // pass this searchResult into cellClass to process or configure
                cell.configure(for: searchResult)
                
                return cell
            }
        }
    }
    
    // handling selection of row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // de-select row after selecting that row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // customization cell before selecting
    // in this case, nothing found cell and loading cell could not be selected
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchBarResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    
 
}
