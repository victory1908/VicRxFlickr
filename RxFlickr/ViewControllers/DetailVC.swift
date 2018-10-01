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
import RxCocoa
import RxDataSources
import RealmSwift

class DetailVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var photo: Photo!
    var realmManager: RealmManager!
    
    enum Mode {
        case search
        case favourite
    }

    var mode: Mode!
    
    // MARK: Rx
    let bag = DisposeBag()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavi()
        setupDetailVC()
        bindUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpNavi() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = mode == .search ? saveButton : deleteButton
    }
    
    func setupDetailVC() {
        let url = photo?.flickrImageURL("b")
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url)
        titleLabel.text = photo?.title ?? ""
    }
    
    func bindUI() {
        
        let naviTap = navigationItem.rightBarButtonItem!.rx.tap.share()
        naviTap.filter {self.mode == .search}
            .subscribe(onNext: {_ in
//                print(Realm.Configuration.defaultConfiguration.fileURL!)
                self.realmManager.saveObjects(objs: self.photo)
            })
            .disposed(by: bag)
        
        naviTap.filter {self.mode == .favourite}
            .subscribe(onNext: {_ in
                self.realmManager.deleteObject(objs: self.photo)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
}
