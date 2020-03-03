//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/3/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImage(url: URL) -> URLSessionDownloadTask {
        
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url) {
            [weak self] url, response, error in
            
            if error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                
                // update UI
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
    
    
    
}
