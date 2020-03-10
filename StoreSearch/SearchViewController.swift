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
    
    private let search = Search()
    
    // for landscape mode
    var landscapeVC: LandscapeViewController?
    
    // for constant identifier of searchResultCell in this SearchViewController file
    struct TableView {
        struct CellIdentifier {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    // Container notifies when its trail collection changes
    // Collection of trails which are such as horizontal size class, vertical size class, display scale(rentina or not), UI idiom (iPhone or iPad), preferred Dynamic Font Size, and other few things
    // in this case, we could determine the size class -> independent of actual device's orientation or dimension
    // with this size class -> we could create a single universal storyboard for all devices (from iphone to ipad)
    // Each of SizeClass (Horizontal or Vertial), it has two other types which are COMPACT and REGULAR
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // vertical size class of trail collection
        // IPAD in portrait mode or landscape mode is in REGULAR in both VERTICAL SIZE CLASS and HORIZONTAL SIZE CLASS
        switch newCollection.verticalSizeClass {
        // VERTICAL SIZE CLASS of IPHONE is COMPACT -> it must be in Landscape mode (in Table)
        case .compact:
            showLandscape(with: coordinator)
            break
        // VERTICAL SIZE CLASS of IPHONE is REGULAR -> it must be in PORTRAIT mode (in Table)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
            break
        @unknown default:
            fatalError()
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
    
    // MARK: - Helper Methods for SearchViewController
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        // add a new CHILD view controller of SearchViewController
        
        // 1
        // if the landscapeVC is nil => create a new one
        guard landscapeVC == nil else { return }
        // 2
        // we dont have "segue" in storyboard, so we must instantiate a new view controller with existing identifier via storyboard
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC { // this is an optional -> must unwrap before using it
            controller.search = search
            
            // 3
            // set size and postion of new controller (LandscapeViewController - controller.view.frame) dependent of view.bounds
            // this will make controller as big as entire screen
            // frame is the rectangle ( with size and location ) in term of superview (superview of new view controller)
            
            controller.view.frame = view.bounds
            controller.view.alpha = 0 // for animation: this view is transparent now
            // 4
            // addSubView will add on top of the SearchViewController, stack on search bar, table view, ...
            view.addSubview(controller.view)
            
            // addChild() will guide view controller with new view controller
            // SearchViewController will be controlled by LandscapeViewController
            addChild(controller) // add the specific view controller as a child of CURRENT controller
            
            /*
            // the new controller (LandscapeViewController) has parent now (SearchViewController)
            // called after removing or adding parent's controller
            controller.didMove(toParent: self) // when the CONTAINER view controller adds or removes a view controller
            */
            
            // FOR ANIMATION
            // this UIViewControllerTransitionCoordinator needs UIViewControllerTransitionCoordinatorContext
            // for smooth transition
            coordinator.animate(alongsideTransition: { _ in
                // the view is now visible
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder() // hide the keyboard
                
                // we also need to hide current modal view which IS PRESENTED via
                // when THIS view controller is presenting a MODAL VIEW -> not nil
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil) // dismiss the view controller which is shown modally
                }
                
                
            }, completion: {
                // we must attach parent's view controller after transition because of being avoided using controller
                _ in
                controller.didMove(toParent: self) // attach parent's VIEW CONTROLLER into this controller after moving or adding
                // => has parent now (NOT parent has child)
            })
            
            // to sum up, SearchViewController is now parent and LandscapeViewController is now a child
            // LandscapeViewController is embedded in SearchViewController
            // it is not presented modally and independent of like a modal screen
            
            
            
        }
    }
    
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            // we must un-attach 2 ways
            
            // called before removing or adding parent's controller
            // like showLandscape method; however, we must un-attach parent's view controller first because of being voided using controller while animation
            controller.willMove(toParent: nil) // no parent now
            
            coordinator.animate(alongsideTransition: {
                _ in
                controller.view.alpha = 0
                self.searchBar.becomeFirstResponder()
                
                
            }, completion: {
                _ in
                controller.view.removeFromSuperview() // un-link VIEW from its superview or parent
                controller.removeFromParent() // un-link VIEW CONTROLLER from its superview or parent
                self.landscapeVC = nil // remove strong reference to LandscapeViewController
            })
            /*
            controller.view.removeFromSuperview() // un-link VIEW from its superview / parent
            controller.removeFromParent() // remove VIEW CONTROLLER from its parent -> parent has no child now
            landscapeVC = nil // remove strong reference to LandscapeViewController
            */
 }
    }
    
    // MARK: - Navigation
    // prepare DATA to pass to ViewController
    // sender is from performSegue in didSelectRowAt
    // sender is indexPath
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if search.state = case of results
        if case .results(let list) = search.state {
            if segue.identifier == "ShowDetail" {
                let detailViewController = segue.destination as! DetailViewController
                
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                }
                
        }
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
        // Search.Category(rawValue): method in enum
        // rawValue maybe non-exist, so it return Optional
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex){
            search.performTask(for: searchBar.text!,
                               category: category,
                               completion: {
                                success in
                                if !success {
                                    self.showNetworkError()
                                }
                                self.tableView.reloadData() })
            
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
    }
    
    
    // setting topView of searchBar
    // delegate for UINavigationBar and UISearchBar -> .top is default
    // UIToolBar -> UIBarPosition.bottom is default
    // .top is the top of its containing View
    // .topAttach is the top of the screen, as well as the containing View
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // set the top of the screen
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
        
        switch search.state {
        case .notSearchedYet: return 0
        case .loading: return 1
        case .noResults: return 2
        case .results(let list): return list.count
        }
//
//        if search.isLoading{
//            return 1
//        } else if !search.hasSearched {
//            return 0
//        } else if search.searchResults.count == 0 {
//            return 1
//        } else {
//            return search.searchResults.count
//        }
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
        
        /*************
        // for showing indication view activity
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            // because we use the custom cell (from nib) => do not use textLabel and detailTextLabel which is from UITableViewCell
            if search.searchResults.count == 0 {
    //            cell.textLabel!.text = "(Nothing found)"
    //            cell.detailTextLabel!.text = ""
                // for NothingFoundCell.xib
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.nothingFoundCell, for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.searchResultCell, for: indexPath) as! SearchResultCell // this will be added into indexPath -> not nil
                
                // cell.textLabel return an optional -> unwrap it
                // extract text (String) from textLabel
                let searchResult = search.searchResults[indexPath.row]
               
                // pass this searchResult into cellClass to process or configure
                cell.configure(for: searchResult)
                
                return cell
            }
        }
        **************/
        
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifier.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
    }
    
    // handling selection of row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // de-select row after selecting that row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // handling action when users selected this row
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    // customization cell before selecting
    // in this case, nothing found cell and loading cell could not be selected
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if search.searchResults.count == 0 || search.isLoading {
//            return nil
//        } else {
//            return indexPath
//        }
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
        
    }
    
    
 
}
