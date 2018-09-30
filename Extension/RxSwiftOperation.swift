//
//  RxSwiftOperation.swift
//  RxFlickr
//
//  Created by victory1908 on 29/9/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

import RxSwift

extension ObservableType {
    
    /**
     Filters the source observable sequence using a trigger observable sequence producing Bool values.
     Elements only go through the filter when the trigger has not completed and its last element was true. If either source or trigger error's, then the source errors.
     - parameter trigger: Triggering event sequence.
     - returns: Filtered observable sequence.
     */
    func filter(if trigger: Observable<Bool>) -> Observable<E> {
        return self.withLatestFrom(trigger) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
    }
}
