//
//  FavouriteVC.swift
//  RxFlickr
//
//  Created by victory1908 on 1/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxRealm
import RealmSwift
import Realm

class FavouriteVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var realmManager: RealmManager!
    
    // MARK : Constants
    
    struct Constant {
        static let cellIdentifier = "cell"
    }
    
    struct Metric {
        static let lineSpacing : CGFloat = 10
        static let intetItemSpacing : CGFloat = 10
        //        static let edgeInset : CGFloat = 8
        static let edgeInset : CGFloat = 10
    }
    
    // MARK : Rx
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavi()
        setUpUI()
    }
    
    func setUpNavi() {
        self.navigationItem.title = "Favourite Images"
    }
    
    func setUpUI() {
        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // RxRealm to get Observable<Results>
        let realm = try! Realm()
        let photoList = realm.objects(Photo.self)
//        // bind to collection view
        Observable.collection(from: photoList)
            .bind(to: collectionView.rx.items(cellIdentifier: Constant.cellIdentifier, cellType: PhotoCell.self)) { (row, photo, cell) in
                let url = photo.flickrImageURL("b")
                cell.flickrPhoto.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)
        
        //-DetailView
        
        let selectedPhoto = self.collectionView.rx.modelSelected(Photo.self).share()
        
        selectedPhoto
            .subscribe(onNext: { photo in
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailVC else {
                    fatalError("DetailViewController not found")
                }
                detailVC.photo = photo
                detailVC.mode = .favourite
                detailVC.realmManager = self.realmManager
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}


// MARK: Extension

extension FavouriteVC: UICollectionViewDelegateFlowLayout {
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
