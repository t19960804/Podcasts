//
//  NetworkService.swift
//  Podcasts
//
//  Created by t19960804 on 3/21/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit
import Combine

class NetworkService {
    static let sharedInstance = NetworkService() //static > 由於其他類別沒辦法初始化NetworkService,所以讓其他類別不需要初始化即可使用屬性
    
    private init(){//private > 防範其他的類別來初始化
        
    }
    var subscriber: AnyCancellable?
    //@escaping > 讓closure在function執行完後可以呼叫(逃離function的生命週期)
    //由於@escaping的closure被呼叫時需要存取到變數 / 常數 / 函式,所以需要加上self.xxx
    //讓self的Reference count + 1,保證closure被呼叫前self不會被釋放掉
    //https://www.jianshu.com/p/9fb444e88d26
    //https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/%E8%AE%93-closure-%E5%9C%A8-function-%E5%A4%96%E7%B9%BC%E7%BA%8C%E4%BD%BF%E7%94%A8%E7%9A%84-escaping-40d50b17f75b
    
    func fetchPodcasts(searchText: String, completion: @escaping (Result<[Podcast],Error>) -> Void){
        //requst url 範例: https://itunes.apple.com/search?term=jack+johnson&media=music
        let urlString = "https://itunes.apple.com/search"
        //下面的寫法不需要對searchText做encoding,因為api自己會enocding,多做一次反而會錯
        //空白鍵 > %20, % > %25
        //也就是說將空白鍵做兩次encoding會變成%2520
        let queryItems = [
                URLQueryItem(name: "term", value: searchText),
                URLQueryItem(name: "media", value: "podcast")
        ]
        guard var urlComps = URLComponents(string: urlString) else {
            let customErr = NetworkServiceError.URLError
            completion(.failure(customErr))
            return
        }
        urlComps.queryItems = queryItems
        guard let url = urlComps.url else {
            let customErr = NetworkServiceError.URLError
            completion(.failure(customErr))
            return
        }
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        subscriber = publisher
            .map { $0.data }
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            //Scheduler > 產生或接收data的Thread
            //預設情況下,接收Data的Scheduler與產生Data的Scheduler是同一個
            .receive(on: DispatchQueue.main)//從Background Thread切到Main Thread收資料
            .sink { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    print("Success fetch podcast")
                }
            } receiveValue: {
                completion(.success($0.results))
            }
    }
    func fetchEpisodes(url: URL, completion: @escaping (Result<[Episode],Error>) -> Void){
        DispatchQueue.global(qos: .background).async {
            let xmlParser = FeedParser(URL: url)//Parser會在Main Thread執行所以會造成UI卡頓
            xmlParser.parseAsync { (result) in
                switch result {
                case .success(let feed):
                    //RSS > 以XML為基礎的內容傳送機制
                    //Feed > 資料來源
                    guard let rssFeed = feed.rssFeed else {
                        print("Error - rssFeed is nil")
                        let customErr = NetworkServiceError.NilRSSFeed
                        completion(.failure(customErr))
                        return
                    }
                    let episodes = rssFeed.getEpisodes()
                    completion(.success(episodes))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

    }
    func downloadEpisode(with episode: EpisodeCellViewModel){
        guard let url = episode.audioUrl else {
            print("Error - AudioUrl has some problem")
            return
        }
        //Download episode to FileManager
        let destination = DownloadRequest.suggestedDownloadDestination()

        AF.download(url, to: destination)
                .downloadProgress { progress in
                    let info: [String : Any] = [
                        Notification.progressKey : Int(progress.fractionCompleted * 100),
                        Notification.episodeKey : episode]
                    NotificationCenter.default.post(name: .progressUpdate, object: nil, userInfo: info)
                }
                .response { (response) in
                    //下載完需要更新剛剛存進Userdefaults的episodeViewModel資訊
                    var downloadEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
                    if let index = downloadEpisodes.firstIndex(where: {
                        $0.title == episode.title && $0.author == episode.author
                    }) {
                        downloadEpisodes[index].fileUrl = response.fileURL
                        downloadEpisodes[index].isWaitingForDownload = false
                    }
                    UserDefaults.standard.saveDownloadEpisode(with: downloadEpisodes)
                    let info: [String : Any] = [Notification.episodeKey : episode]
                    NotificationCenter.default.post(name: .episodeDownloadDone, object: nil, userInfo: info)
                }
    }
}
//https://riptutorial.com/swift/example/28601/create-custom-error-with-localized-description
enum NetworkServiceError: Error {
    case NilRSSFeed
    case NilPodcastData
    case URLError
}
extension NetworkServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NilRSSFeed:
            return NSLocalizedString("Nil rss feed", comment: "Nil rss feed")
        case .NilPodcastData:
            return NSLocalizedString("Nil podcast data", comment: "Nil podcast data")
        case .URLError:
            return NSLocalizedString("URL err", comment: "URL error")
        }
    }
}
