//
//  DetailViewController.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class DetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var photo: Photo?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        navigationController?.hidesBarsOnSwipe = false
        setupDetailVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    func setupDetailVC() {
        let url = URL(string: photo?.flickrURLMedium() ?? "")
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url)
        titleLabel.text = photo?.title ?? ""
    }
    
    
}
