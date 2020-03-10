//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/4/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // IBOUtlet
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    enum AnimationType {
        case slide
        case fade
    }
    
    var dismissType = AnimationType.fade
    
    
    // this is invoked to load the view controller from the storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        modalPresentationStyle = .custom // modal style of this ViewController (instead of )
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceButton.setBackgroundImage(UIImage(named: "PriceButton"), for: .normal)
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        // add gestureRecognizer to view in order to dismiss the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        
        // need to set cancelsTouchesInView = false (to deliver gesture to view)
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self // and also set the delegate to self which conformed in extenstion
        view.addGestureRecognizer(gestureRecognizer)
        
        // setting the view itself is transparent
        view.backgroundColor = UIColor.clear
        
        if searchResult != nil {
            updateUI()
        }
    }
    

    // MARK: - Actions
    @IBAction func close() {
        dismissType = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    // MARK: - Helper Methods
    func updateUI(){
        nameLabel.text = searchResult.name
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artist
        }
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        // show the price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, for: .normal)
        
        // show artwork
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// conform the transition delegate for this View (DetailViewController)
extension DetailViewController: UIViewControllerTransitioningDelegate {
    // present the DimmingPresentationController --> PRESENTING VIEWCONTROLLER
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented,
                                             presenting: presenting)
    }
    
    
    // for animating this transition
    // dismiss's animation for DimmingPresentationController
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: - creating a new AnimationController for dismission ???
//        return SlideOutAnimationController()
        
        switch dismissType {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
        
    }
    
    // apply and present the animation (BounceAnimationController) for DimmingPresentationController
    // animate OBJECTS when PRESENTINGS a VIEWCONTROLLER
    // in BounceAnimationController (must return an object -> addSubView to Container)
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
}

// conform the GestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
