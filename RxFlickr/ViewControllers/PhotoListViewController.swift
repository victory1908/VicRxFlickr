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
    
    var sharePhotos: [Photo] = []
    var isSharing = false
    
    let shareTextLabel = UILabel()
    
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
    
    fileprivate func setUpSearchViewController() {

        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search Images"
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        else {
            present(searchController, animated: true, completion: nil)
        }
        
    }
    
    func showSearchController(showSearchBar: Bool) {
        UIView.setAnimationsEnabled(true)
        searchController.isActive = showSearchBar
        searchController.isActive = !showSearchBar
        UIView.setAnimationsEnabled(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search RxFlickr"
        
        //        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
        setUpSearchViewController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSearchController(showSearchBar: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Constraints
    
    // MARK: Binding
    
    func bind(reactor: PhotoListViewReactor) {
        // DataSource
        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Bind CollectionView
        reactor.state.map {$0.photos}
            //                .replaceNilWith([])
            .bind(to: collectionView.rx.items(cellIdentifier: Constant.cellIdentifier, cellType: PhotoCell.self)) { (row, photo, cell) in
                let url = URL(string: photo.flickrURLSmall())
                cell.flickrPhoto.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)
        
        // Action
        
        // Search
        self.searchController.searchBar.rx.text
            .orEmpty.changed.throttle(0.3, scheduler: MainScheduler.instance)
            .filter { $0.isNotEmpty }
            .distinctUntilChanged()
            .map {Reactor.Action.updateQuery($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // LoadMore
        self.collectionView.rx.contentOffset
            .filter { [weak self] offset in
                guard let strongSelf = self else { return false }
                guard strongSelf.collectionView.frame.height > 0 else { return false }
                return offset.y + strongSelf.collectionView.frame.height >= strongSelf.collectionView.contentSize.height - 100
            }
            .throttle(0.3, scheduler: MainScheduler.instance)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Share
        
        reactor.state.map{$0.isSharing}
            .subscribe(onNext: {
            self.collectionView.allowsMultipleSelection = $0
        }).disposed(by: disposeBag)

        reactor.state.map{$0.isSharing}
            .subscribe(onNext: { isSharing in
                
                self.title = isSharing ? "Choose item to share" : "Rx Search"
                
//                guard let shareButton = self.navigationItem.rightBarButtonItems?.first else {
//                    return
//                }
//                if (isSharing) {
//                    self.shareTextLabel.textColor = .red
//                    self.shareTextLabel.sizeToFit()
////                    self.shareTextLabel.text = "\(self.sharePhotos.count) selected"
//                    let sharingDetailItem = UIBarButtonItem(customView: self.shareTextLabel)
//                    self.navigationItem.setRightBarButtonItems([shareButton,sharingDetailItem], animated: true)
//
//                } else {
//                    self.navigationItem.setRightBarButtonItems([shareButton], animated: true)
//
//                }
            })
            .disposed(by: disposeBag)
        
        
        let shareButtonTap = self.navigationItem.rightBarButtonItems!.first!.rx.tap.throttle(3, scheduler: MainScheduler.instance)
            .share()
        
        let selectedPhoto = self.collectionView.rx.modelSelected(Photo.self).share()
        let deSelectedPhoto = self.collectionView.rx.modelDeselected(Photo.self).share()
        
        selectedPhoto
            .filter(if: reactor.state.map{$0.isSharing})
            .subscribe(onNext: { photo in
                self.sharePhotos.append(photo)
            }).disposed(by: disposeBag)
        
        deSelectedPhoto
            .filter(if: reactor.state.map{$0.isSharing})
            .subscribe(onNext: { photo in
                self.sharePhotos.removeAll(where: { $0.id == photo.id })
            }).disposed(by: disposeBag)
        
        shareButtonTap
            .filter(if: reactor.state.map{!$0.isSharing})
            .map{Reactor.Action.shareInit}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
       
        
        let confirmShare = shareButtonTap
            .filter(if: reactor.state.map{$0.isSharing})
            //            .filter(if: reactor.state.map{$0.sharePhotos}.map{$0.isNotEmpty})
            .filter{self.sharePhotos.isNotEmpty}.share()
        
        confirmShare
            .map {
                Photo.downloadImages(urls: self.sharePhotos.map{$0.flickrImageURL("b")!})
            }.flatMap{$0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { photosImages in
                print (photosImages.count)
                print("share confirm")
                
                self.collectionView.deselectAllItems(animated: false)
                
                let ac = UIActivityViewController(activityItems: photosImages as! [UIImage], applicationActivities: nil)
                
                ac.completionWithItemsHandler = { (activity, success, items, error) in
                    if error == nil {
                        let alert = UIAlertController(title: "success", message: "complete", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        self.sharePhotos.removeAll()
                    } else {
                        let alert = UIAlertController(title: "fail", message: "fail", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                self.present(ac, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        confirmShare.map{Reactor.Action.shareFinish}
                    .bind(to: reactor.action)
                    .disposed(by: disposeBag)
        
        //DetailView
        
        selectedPhoto
            .filter{_ in
                self.collectionView.allowsMultipleSelection == false
            }
            .subscribe(onNext: { photo in
                guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                    fatalError("DetailViewController not found")
                }
                detailVC.photo = photo
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
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
