//
//  AppService.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import RxSwift
import Alamofire
import UIKit

class AppService {
    static let BASE_URL = "https://api.flickr.com/services/rest/"
    static var parameters = [
        "method": "flickr.photos.search",
        "api_key": "739b660ea3629666d04b83ad0a19a381",
        "format": "json",
        "per_page": "30",
        "nojsoncallback": "1",
        ]
    
    static let headers = [
        "Content-Type": "application/json"
    ]
    
    static func request(_ query: String, _ page: Int) -> Observable<(photos: [Photo], nextPage: Int)> {
        return Observable.create { observer -> Disposable in
            var params = parameters
            params["page"] = "\(page)"
            params["text"] = query
            
            Alamofire.request(BASE_URL, parameters: params, headers: headers).responseData { response in
                switch response.result {
                case .success(let value):
                    let photos = Photo.photosFromApi(data: value)
                    let nextPage = page + 1
                    observer.onNext(((photos ?? []),nextPage))
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                    print("error in network")
                    print(error)
                }
            }
            return Disposables.create()
        }
    }
    
//    static func sharePhotos (_ photos: [Photos]) -> Observable<()> {
//        return Observable.create({ (observer) -> Disposable in
//
//            let UIAC
//
//            return Disposables.create()
//        })
//
//    }
    
}

