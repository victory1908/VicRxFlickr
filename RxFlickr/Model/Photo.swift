
import Foundation
import RxSwift

struct Response: Codable {
    let photos: Photos?
    let stat: String?
}

struct Photos: Codable {
    let page, pages, perpage: Int?
    let total: String?
    let photo: [Photo]?
}

struct Photo: Codable {
    let id, owner, secret, server: String?
    let farm: Int?
    let title: String?
    let ispublic, isfriend, isfamily: Int?
}

extension Photo {

    func flickrURLSmall() -> String{
        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg"
    }

    func flickrURLMedium() -> String{
        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_c.jpg"
    }

    func flickrURLOriginal() -> String{
        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_o.jpg"
    }
    
    func flickrImageURL(_ size:String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_\(size).jpg") {
            return url
        }
        return nil
    }
    
    static func photosFromApi(data: Data) -> [Photo]? {

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let photos = try jsonDecoder.decode(Response.self, from: data).photos?.photo
            return photos
        } catch let error{
            print("error decoding \(error)")
            return nil
        }
    }
    
    static func downloadImage(url: URL) -> Observable<UIImage?> {
        return URLSession.shared.rx
            .data(request: URLRequest(url: url))
            .map { data in UIImage(data: data) }
            .catchErrorJustReturn(nil)
    }
    
    static func downloadImages(urls: [URL]) -> Observable<[UIImage?]> {
        return Observable.from(urls).flatMap{self.downloadImage(url: $0)}.toArray().subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    
}
