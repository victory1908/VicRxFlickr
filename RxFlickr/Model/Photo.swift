
import Foundation
import RxSwift
import RealmSwift
import Realm

struct Response: Decodable {
    let photos: Photos?
    let stat: String?
}

struct Photos: Decodable {
    let page, pages, perpage: Int?
    let total: String?
    let photo: [Photo]?
}

//struct Photo: Codable {
//    let id, owner, secret, server: String?
//    let farm: Int?
//    let title: String?
//    let ispublic, isfriend, isfamily: Int?
//}

@objcMembers class Photo: Object, Decodable {
    
    dynamic var id = ""
    dynamic var owner = ""
    dynamic var secret = ""
    dynamic var server = ""
    dynamic var title = ""
    dynamic var farm = 0
    dynamic var ispublic = 0
    dynamic var isfriend = 0
    dynamic var isfamily = 0
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum PhotoCodingKeys: String, CodingKey {
        case farm, isfriend, ispublic, isfamily, id, owner, secret, server, title
    }
    
    convenience init(id: String, owner: String, secret: String, server: String, farm: Int, title: String, ispublic: Int, isfriend: Int, isfamily: Int) {
        self.init()
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.ispublic = ispublic
        self.isfriend = isfriend
        self.isfamily = isfamily
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotoCodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let owner = try container.decode(String.self, forKey: .owner)
        let secret = try container.decode(String.self, forKey: .secret)
        let server = try container.decode(String.self, forKey: .server)
        let farm = try container.decode(Int.self, forKey: .farm)
        let title = try container.decode(String.self, forKey: .title)
        let ispublic = try container.decode(Int.self, forKey: .ispublic)
        let isfriend = try container.decode(Int.self, forKey: .isfriend)
        let isfamily = try container.decode(Int.self, forKey: .isfamily)
        
        
        self.init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title, ispublic: ispublic, isfriend: isfriend, isfamily: isfamily)
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}



extension Photo {
    
    
    func flickrImageURL(_ size:String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg") {
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














//
//import Foundation
//import RxSwift
//
//struct Response: Codable {
//    let photos: Photos?
//    let stat: String?
//}
//
//struct Photos: Codable {
//    let page, pages, perpage: Int?
//    let total: String?
//    let photo: [Photo]?
//}
//
//struct Photo: Codable {
//    let id, owner, secret, server: String?
//    let farm: Int?
//    let title: String?
//    let ispublic, isfriend, isfamily: Int?
//}
//
//extension Photo {
//
//    func flickrURLSmall() -> String{
//        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg"
//    }
//
//    func flickrURLMedium() -> String{
//        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_c.jpg"
//    }
//
//    func flickrURLOriginal() -> String{
//        return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_o.jpg"
//    }
//
//    func flickrImageURL(_ size:String = "m") -> URL? {
//        if let url =  URL(string: "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_\(size).jpg") {
//            return url
//        }
//        return nil
//    }
//
//    static func photosFromApi(data: Data) -> [Photo]? {
//
//        let jsonDecoder = JSONDecoder()
//        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        do {
//            let photos = try jsonDecoder.decode(Response.self, from: data).photos?.photo
//            return photos
//        } catch let error{
//            print("error decoding \(error)")
//            return nil
//        }
//    }
//
//    static func downloadImage(url: URL) -> Observable<UIImage?> {
//        return URLSession.shared.rx
//            .data(request: URLRequest(url: url))
//            .map { data in UIImage(data: data) }
//            .catchErrorJustReturn(nil)
//    }
//
//    static func downloadImages(urls: [URL]) -> Observable<[UIImage?]> {
//        return Observable.from(urls).flatMap{self.downloadImage(url: $0)}.toArray().subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
//    }
//
//
//}
