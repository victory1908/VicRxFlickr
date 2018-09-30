//
//  UICollectionViewEx.swift
//  RxFlickr
//
//  Created by victory1908 on 30/9/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}
