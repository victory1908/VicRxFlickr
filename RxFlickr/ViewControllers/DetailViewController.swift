//
//  DetailViewController.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var photo = Photo()
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        setupDetailVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupDetailVC() {
        let url = URL(string: photo!.flickrURL())
        self.imageView.kf.setImage(with: url)
        
        self.titleLabel.text = photo!.title!
    }
    
}
