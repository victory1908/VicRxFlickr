//
//  UICollectionViewEx.swift
//  RxFlickr
//
//  Created by victory1908 on 30/9/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import RxRealm

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
    
    func applyChangeset(_ changes: RealmChangeset) {
        performBatchUpdates({
            deleteItems(at: changes.deleted.map { IndexPath(row: $0, section: 0) })
            insertItems(at: changes.inserted.map { IndexPath(row: $0, section: 0) })
            reloadItems(at: changes.updated.map { IndexPath(row: $0, section: 0) })

        })
            
    }

}
