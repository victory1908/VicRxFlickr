//
//  CollectionViewCell.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  
  // MARK: Properties
  
    @IBOutlet weak var flickrPhoto: UIImageView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.flickrPhoto.image = nil
  }
  
}
