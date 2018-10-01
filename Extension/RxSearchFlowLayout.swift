//
//  RxSearchFlowLayout.swift
//  RxFlickr
//
//  Created by victory1908 on 1/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit

class RxSearchFlowLayout: UICollectionViewFlowLayout {
    
    struct Metric {
        static let lineSpacing : CGFloat = 10
        static let intetItemSpacing : CGFloat = 10
        //        static let edgeInset : CGFloat = 8
        static let edgeInset : CGFloat = 10
    }
    
    //DelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - 40) * 0.33,
                      height: (collectionView.bounds.size.width - 40) * 0.33)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) ->CGFloat {
        return Metric.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.intetItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: Metric.edgeInset,
                                 left: Metric.edgeInset,
                                 bottom: Metric.edgeInset,
                                 right: Metric.edgeInset)
    }
}
