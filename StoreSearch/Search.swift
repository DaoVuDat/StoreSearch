//
//  Search.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/10/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation

class Search {
//    var searchResults: [SearchResult] = []
//    var hasSearched = false
//    var isLoading = false
    
    private var dataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    
    typealias SearchComplete = (Bool) -> Void
    
    // ASSOCIATED 
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    
    func performTask(for text: String, category: Category, completion: @escaping SearchComplete) {
        print("Searching")
        
        if !text.isEmpty {
            dataTask?.cancel()
            
            let url = iTunesURL(searchText: text, category: category)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                
                var newState = State.notSearchedYet
                var success = false
                
                // was the search cancelled?
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    let searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        newState = .results(searchResults)
                    }
                    success = true
                }
                
                
                
                DispatchQueue.main.async {
                    self.state = newState
                    // completion is closure
                    // this run on main thread -> safe to update UI
                    completion(success)
                }
            })
            
            dataTask?.resume()
        }
        
    }
    
    // MARK: - Helper Methods for UISearchBarDelegate
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
       
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

    
    
    private func parse(data: Data) -> [SearchResult] {
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
}
