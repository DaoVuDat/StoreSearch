//
//  SearchResult.swift
//  StoreSearch
//
//  Created by DaoVuDat on 2/27/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation

// all of this must be conformed the Codable Protocol, even in SearchResult

class ResultArray: Codable {
    var resultCount = 0
    var results: [SearchResult] = []
}


// everything from Web Services should go with Optional because of Codable
class SearchResult: Codable, CustomStringConvertible {
    // this computed variable description is conformed CustomStringConvertible
    var description: String {
        return "Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")\n"
    }
    
    // properties from
    var trackName: String? = ""
    var artistName: String? = ""
    var kind: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    
    // these variable's name are from web service api
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    
    
    // MARK: - Computed Variables
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double {
        // if track price is nil -> check the price of collectionPrice and so on. return default 0.0 value when there is no price in responsed data
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        
        switch kind {
        case "album": return "Album"
        case "book": return "Book"
        case "audiobook": return "Audio Book"
        case "ebook": return "E-book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "Software"
        case "song": return "Song"
        case "tv-episodes": return "TV Episode"
        default: break
        }
        
        return "Unknown"
    }
    
    var artist: String {
        return artistName ?? ""
    }
    
    // CodingKey protocol in order that we could change the key for encoding and decoding
    // change the key in web service such as artworkUrl60, trackViewUrl into imageSmall, storeURL respectively
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case kind, artistName, trackName
        case trackPrice, currency
        case collectionName, collectionPrice, collectionViewUrl
        case itemPrice = "price"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
    }
}
