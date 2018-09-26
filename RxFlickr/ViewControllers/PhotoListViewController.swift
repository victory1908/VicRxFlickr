//
//  ViewController.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import RxCocoa
import RxSwift
import RxDataSources
import ReusableKit
import Then
import ReactorKit
import RxOptional

struct SectionOfPhoto {
    var header: String
    var items: [Item]
}
extension SectionOfPhoto: SectionModelType {
    typealias Item = Photo
    
    init(original: SectionOfPhoto, items: [Item]) {
        self = original
        self.items = items
    }
}

//class PhotoListViewController: UIViewController, ReactorKit.View {
class PhotoListViewController: UIViewController, StoryboardView {
    
    // MARK : Constants
    
    struct Reusable {
        static let flickrCell = ReusableCell<PhotoCell>()
    }
    
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
    
    // MARK: Properties
    
    let dataSources = RxCollectionViewSectionedReloadDataSource<SectionOfPhoto>(configureCell: { dataSource,
        collectionView,
        indexPath,
        item in
        let cell = collectionView.dequeue(Reusable.flickrCell, for: indexPath)
        let url = URL(string: item.flickrURL())
        cell.flickrPhoto.kf.setImage(with: url)
        
        return cell
    })
    
    let searchBar = UISearchBar(frame: .zero).then{
        $0.searchBarStyle = .prominent
        $0.placeholder = "Search Flickr"
        $0.sizeToFit()
    }
    
    let collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero
            , collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(Reusable.flickrCell)
        return collectionView
    }()
    
    // MARK: Initializing
    
    init(reactor: PhotoListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search RxFlickr"
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.collectionView)
        
        setupConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Constraints
    
    
    func setupConstraints() {
        self.collectionView.snp.makeConstraints{ make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
        
        self.searchBar.snp.makeConstraints{ make in
            make.top.equalTo(self.view).offset(20 + 44)
            make.left.right.equalTo(self.view)
        }
    }
    
    // MARK: Binding
    
    func bind(reactor: PhotoListViewReactor) {
        // DataSource
        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        self.collectionView.rx.modelSelected(Photo.self)
            .subscribe(onNext: { photo in
                let view = DetailViewController()
                view.photo = photo
                self.navigationController?.pushViewController(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Action
        
        // Search
        self.searchBar.rx.text
            .filterNil()
            .debounce(1.0, scheduler: MainScheduler.instance)
//            .throttle(0.3, scheduler: MainScheduler.instance)
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
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.photos }
            .replaceNilWith([])
            .asDriver(onErrorJustReturn: [])
//            .drive(collectionView.rx.items(dataSource: dataSources))
            .drive(collectionView.rx.items) { (collectionView, row, photo) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeue(Reusable.flickrCell, for: indexPath)
                let url = URL(string: photo.flickrURL())
                cell.flickrPhoto.kf.setImage(with: url)
                
                return cell
            }
            .disposed(by: disposeBag)
        
//        // State
//        reactor.state.map { $0.photos }
//            .replaceNilWith([])
//            .bind(to: collectionView.rx.items(dataSource: dataSources))
//            .disposed(by: disposeBag)
        
//        // State
//        reactor.state.map {$0.photos}
//            .bind(to: collectionView.rx.items(dataSource: dataSources))
//            .disposed(by: disposeBag)
        
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

