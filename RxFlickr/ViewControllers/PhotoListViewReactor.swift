//
//  PhotoListViewReactor.swift
//  RxFlickr
//
//  Created by victory1908 on 2018. 9. 26..
//  Copyright © 2018 Victory1908. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class PhotoListViewReactor : Reactor {
    
    enum Action {
        case updateQuery(_ query: String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(_ query: String?)
        case setPhotos(_ photos: [Photo], nextPage: Int?)
        case appendPhotos(_ photos: [Photo], nextPage: Int?)
        case setLoadingNextPage(Bool)
    }
    
    struct State {
        var query: String?
        var photos: [Photo]?
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    struct testStruct {
        var photos: [Photo] = []
    }
    
    var initialState = State()
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case .updateQuery(let query):
                
                return Observable.concat([
                        Observable.just(Mutation.setQuery(query)),
                        // 2) call API and set repos (.setRepos)
                        AppService.request(query!, 1)
                        // cancel previous request when the new `.updateQuery` action is fired
//                                .takeUntil(self.action.filter(isUpdateQueryAction))
                                .map { Mutation.setPhotos($0, nextPage: $1) }
                ])
            case .loadNextPage:
                guard !self.currentState.isLoadingNextPage else { return Observable.empty() }
                guard let page = self.currentState.nextPage else { return Observable.empty() }
                return Observable.concat([
                    // 1) set loading status to true
                    Observable.just(Mutation.setLoadingNextPage(true)),
                
                    // 2) call API and append repos
                    AppService.request(self.currentState.query!, page)
//                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.appendPhotos($0, nextPage: $1) },
                
                    // 3) set loading status to false
                    Observable.just(Mutation.setLoadingNextPage(false)),
                    ])

        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState
            
        case let .setPhotos(photos, nextPage):
            var newState = state
            newState.photos = photos
            newState.nextPage = nextPage
            return newState
            
        case let .appendPhotos(photos, nextPage):
            var newState = state
            newState.photos!.append(contentsOf: photos)
            newState.nextPage = nextPage
            return newState
            
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        }
    }
    
//    private func isUpdateQueryAction(_ action: Action) -> Bool {
//        if case .updateQuery = action {
//            return true
//        } else {
//            return false
//        }
//    }
    
}
