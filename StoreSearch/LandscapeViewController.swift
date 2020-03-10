//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/7/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults: [SearchResult] = []
    
    private var firstTime = true // for placing Button once
    private var downloads = [URLSessionDownloadTask]() // keep track of all the "active" URLSessionDownloadTask
    
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel() // cancel each task when user change into portrait screen
            // cancel task which is pending or transfering
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Removing Auto Layout because Interface Builder will add them automatically
        // remove contrainst from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true // if true, we could set Frame, Bounds,... manually of this size and position
    
        // remove constraint from page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        // remove constraint from scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.delegate = self
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        // setting page controll
        pageControl.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        
        pageControl.frame = CGRect(x: safeFrame.origin.x,
                                   y: safeFrame.size.height - pageControl.frame.size.height,
                                   width: safeFrame.size.width,
                                   height: pageControl.frame.size.height)
        pageControl.backgroundColor = UIColor.clear
        
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 6
        var rowsPerPage = 3
        var itemWidth: CGFloat = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 2
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            // 4 inches screen
            break
            
        case 667:
            // 4.7 inches
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            break
            
        case 736:
            // 5.5 inches
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            marginX = 0
            break
            
        case 724:
            // iphoneX
            columnsPerPage = 8
            rowsPerPage = 3
            itemWidth = 90
            itemHeight = 98
            marginX = 2
            marginY = 29
            break
            
        default:
            break
        }
        
        // button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        // add buttons
        var row = 0
        var column = 0
        var x = marginX
        for (_, result) in searchResults.enumerated() {
            //
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
//            button.backgroundColor = UIColor.white
//            button.setTitle("\(index)", for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            
            //
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            
            //
            scrollView.addSubview(button)
            
            //
            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
                
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        
        // set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, // number of pages * per screen (width of view)
                                        height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        // assing numPages
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        // get the String Image of searchResult
        if let url = URL(string: searchResult.imageSmall){
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
                if  error == nil,
                    let url = url,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // button weak link here because when user back to portrait, we need to halt the download process -> avoid ownership cycle
                        // if user changes into portrait mode -> button is not exist (nil)
                        // if let will avoid setImage into button
                        if let button = button {
                            button.setImage(image, for: .normal)
                        } // if let button
                    } // DispatchQueue
                } // if let chain
            } // let task
            downloads.append(task)
            task.resume()
        }
        
    }

}


// Scrollview delegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width // the width of scrollView >< contentSize
//        print("=== scrollViewDidScroll")
//        print("Width: \(width)")
//        print("ScrollViewContentOffetX: \(scrollView.contentOffset.x)")
//        print("LHS: \(scrollView.contentOffset.x + width / 2)")
        // contentOffset => toa do hien gio cua ScrollView CONTENT (may be larger than device's screen)
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        
        pageControl.currentPage = page
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        print(sender.currentPage)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                            self.scrollView.contentOffset = CGPoint(
                                x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                y: 0)
                        }, completion: nil)
        
       
    }
}
