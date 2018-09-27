//
//  ViewController.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import ReactorKit
import RxOptional

class PhotoListViewController: UIViewController, StoryboardView {
    
// MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
    
    
// MARK: Initializing
    
// MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search RxFlickr"
        
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        UIView.setAnimationsEnabled(true)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
//        UIView.setAnimationsEnabled(false)
        searchController.isActive = true
        searchController.isActive = false
//        UIView.setAnimationsEnabled(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: Constraints
    
// MARK: Binding
    
    func bind(reactor: PhotoListViewReactor) {
        // DataSource
        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        self.collectionView.rx.modelSelected(Photo.self)
            .subscribe(onNext: { photo in
                
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                    fatalError("DetailViewController not found")
                }
                detailVC.photo = photo
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
    // Action
        
        // Search
        self.searchController.searchBar.rx.text
            .filterNil()
            .filter{$0 != ""}
            .debounce(1.0, scheduler: MainScheduler.instance)
//            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do {
                print("fired")
                self.collectionView.reloadData()
            }
            .map {Reactor.Action.updateQuery($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // LoadMore
        self.collectionView.rx.contentOffset
//            .filter{ bool in return bool && (searchBar.text! != "")}
            .filter { [weak self] offset in
                guard let strongSelf = self else { return false }
                guard strongSelf.collectionView.frame.height > 0 else { return false }
                return offset.y + strongSelf.collectionView.frame.height >= strongSelf.collectionView.contentSize.height - 100
            }
            .throttle(0.3, scheduler: MainScheduler.instance)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do {print("fired")}
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Bind CollectionView
        reactor.state.map {$0.photos}
//                .replaceNilWith([])
            .bind(to: collectionView.rx.items(cellIdentifier: Constant.cellIdentifier, cellType: PhotoCell.self)) { (row, photo, cell) in
                let url = URL(string: photo.flickrURL())
                cell.flickrPhoto.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)
        
        //Misc feature
        
        // searchbar keyboard when scroll
        collectionView.rx.didScroll.subscribe {_ in
            // Dismiss searchviewcontroller keyboard when scroll
            if self.searchController.searchBar.isFirstResponder {
                _ = self.searchController.resignFirstResponder()
            }
            
//            if (self.collectionView.panGestureRecognizer.translation(in: self.collectionView.superview).y > 0) {
//                // scroll up
//                self.searchController.isActive = true
//            } else {
//                //scroll down
//                self.searchController.isActive = false
//            }
            }.disposed(by:disposeBag)
    }
}

// MARK: Extension

extension PhotoListViewController: UICollectionViewDelegateFlowLayout{
    
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


