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
        case updateQuery(_ query: String)
        case loadNextPage
        case setSharingState(isSharing: Bool)
        case select(photo: Photo)
        case deselect(photo: Photo)
        case shareConfirm
        case shareFinish
    }
    
    enum Mutation {
        case setQuery(_ query: String)
        case setPhotos(_ photos: [Photo], nextPage: Int)
        case appendPhotos(_ photos: [Photo], nextPage: Int)
        case setLoadingNextPage(Bool)
        case selectShare(_ photo: Photo)
        case deselectShare(_ photo: Photo)
        case setSharingState(Bool)
        case triggerShareAction
        case shareComplete
    }
    
    struct State {
        var query: String = ""
        var photos: [Photo] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
        var sharePhotos: [Photo] = []
        var sharePhotoIMG: Observable<[UIImage?]> = Observable.empty()
        var isSharing: Bool = false
        var shareAction: Bool = false
    }
    
    var initialState = State()
    
    //    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            
            return Observable.concat([
                Observable.just(Mutation.setQuery(query)),
                // 2) call API and set repos (.setRepos)
                AppService.request(query, 1)
                    // cancel previous request when the new `.updateQuery` action is fired
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.setPhotos($0, nextPage: $1) }
                //                                .do {print("")}
                ])
        case .loadNextPage:
            guard !self.currentState.isLoadingNextPage else { return Observable.empty() } //prevent multiple request
            guard let page = self.currentState.nextPage else { return Observable.empty() }
//            let page = self.currentState.nextPage
            
            return Observable.concat([
                // 1) set loading status to true
                Observable.just(Mutation.setLoadingNextPage(true)),
                
                // 2) call API and append repos
                AppService.request(self.currentState.query, page)
                    .takeUntil(self.action.filter(isUpdateQueryAction))
                    .map { Mutation.appendPhotos($0, nextPage: $1) },
                
                // 3) set loading status to false
                Observable.just(Mutation.setLoadingNextPage(false)),
                ])
            
        case .select(photo: let photo):
            return Observable.just(Mutation.selectShare(photo)).takeUntil(self.action.filter(isSharingAction))

        
        case .deselect(photo: let photo):
            return Observable.just(Mutation.deselectShare(photo)).takeUntil(self.action.filter(isSharingAction))

        case .setSharingState(isSharing: let isSharing):
            return Observable.just(Mutation.setSharingState(isSharing))
         
        case .shareConfirm:
            return Observable.concat([Observable.just(Mutation.triggerShareAction),
                                      Observable.just(Mutation.shareComplete),
                                      Observable.just(Mutation.setSharingState(false))])
        case .shareFinish:
            return Observable.concat([Observable.just(Mutation.shareComplete),Observable.just(Mutation.setSharingState(false))])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            newState.nextPage = 1
            return newState
            
        case let .setPhotos(photos, nextPage):
            var newState = state
            newState.photos = photos
            newState.nextPage = nextPage
            return newState
            
        case let .appendPhotos(photos, nextPage):
            var newState = state
            newState.photos.append(contentsOf: photos)
            newState.nextPage = nextPage
            return newState
            
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        
        case let .selectShare(photo):
            var newState = state
            newState.sharePhotos.append(photo)
            return newState
        
        case let .deselectShare(photo):
            var newState = state
            newState.sharePhotos.removeAll(where: { $0.id == photo.id })
            return newState
            
        case let .setSharingState(isSharing):
            var newState = state
            newState.isSharing = isSharing
            return newState
            
        case .triggerShareAction:
            var newState = state
            newState.shareAction = true
            newState.sharePhotoIMG = Photo.downloadImages(urls: newState.sharePhotos.map{$0.flickrImageURL("b")!})
            
            return newState
        
        case .shareComplete:
            var newState = state
            newState.shareAction = false
            newState.isSharing = false
            newState.sharePhotos = []
            newState.sharePhotoIMG = Observable.empty()
            return newState
        }
    }
    
    private func isUpdateQueryAction(_ action: Action) -> Bool {
        if case .updateQuery = action {
            return true
        } else {
            return false
        }
    }
    
    private func isSharingAction(_ action: Action) -> Bool {
        if case Action.setSharingState(isSharing: true) = action {
            return true
        } else {
            return false
        }
    }
}

