//
//  NetworkService.swift
//  Podcasts
//
//  Created by t19960804 on 3/21/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import FeedKit
import Combine

//為何不用struct來設計Singleton?
//因為struct為value type,代表其他人對於Singleton的操作可能不會反映到Singleton
//這樣就違反了Singleton的唯一性,因為每個人看到的Singleton的狀態都不一致
class NetworkService {
    
    static let sharedInstance = NetworkService()
    private var session: URLSessionProtocol = URLSession.shared
    private init(){
        
    }
    func replaceSession(with session: URLSessionProtocol){
        self.session = session
    }
    func fetchPodcasts(searchText: String) -> AnyPublisher<SearchResult, Error> {
        if searchText.isEmpty {
            let result = SearchResult(resultCount: 0, results: [])
            let publisher = Just(result)
            return publisher
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
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
            return Fail(error: customErr).eraseToAnyPublisher()
        }
        urlComps.queryItems = queryItems
        guard let url = urlComps.url else {
            let customErr = NetworkServiceError.URLError
            return Fail(error: customErr).eraseToAnyPublisher()
        }
        let publisher = session.dataTaskPublisher(for: url)
        return publisher
            .map { $0.data }
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            //Scheduler > 產生或接收data的Thread
            //預設情況下,接收Data的Scheduler與產生Data的Scheduler是同一個
            .receive(on: DispatchQueue.main)
            //.eraseToAnyPublisher() > 將型別中間的Operator抹除, 但是仍保留 Operator 的功能(簡化型別)
            .eraseToAnyPublisher()
    }
    //Replace Completion-Handler Closures with Futures
    //Future > A publisher that performs some work and then asynchronously signals success or failure.
    //Promise >  A closure that receives the element produced by the future
    
    func fetchEpisodes(url: URL) -> Future<[Episode],Error> {
        return Future() { promise in
            DispatchQueue.global(qos: .background).async {
                let xmlParser = FeedParser(URL: url)
                xmlParser.parseAsync { (result) in
                    switch result {
                    case .success(let feed):
                        guard let rssFeed = feed.rssFeed else {
                            promise(Result.failure(NetworkServiceError.NilRSSFeed))
                            return
                        }
                        let episodes = rssFeed.getEpisodes()
                        promise(Result.success(episodes))
                    case .failure(let error):
                        promise(Result.failure(error))
                    }
                }
            }
        }
        

    }
    private var observation: NSKeyValueObservation?
    func downloadEpisode(with episode: EpisodeCellViewModel) -> Future<URL, Error> {
        return Future { [unowned self] (promise) in
            guard let url = episode.audioUrl else {
                print("Error - AudioUrl has some problem")
                promise(Result.failure(NetworkServiceError.URLError))
                return
            }
            let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
                if let error = error {
                    print("Download file failed:\(error)")
                    promise(Result.failure(error))
                    return
                }
                //載下來的data會存在.tmp檔,還需要將data取出寫成.mp3檔
                //https://stackoverflow.com/questions/50383343/urlsession-download-from-remote-url-fail-cfnetworkdownload-gn6wzc-tmp-appeared
                guard let tmpFileUrl = url else {
                    print("Err - Download file success, but url is nil")
                    promise(Result.failure(NetworkServiceError.URLError))
                    return
                }
                promise(Result.success(tmpFileUrl))
                let info = [Notification.episodeKey : episode]
                NotificationCenter.default.post(name: .episodeDownloadDone, object: nil, userInfo: info)
            }
            //Observe progress
            //https://stackoverflow.com/questions/30543806/get-progress-from-datataskwithurl-in-swift/54204979#54204979
            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                let info: [String : Any] = [
                    Notification.progressKey : Int(progress.fractionCompleted * 100),
                    Notification.episodeKey : episode]
                NotificationCenter.default.post(name: .progressUpdate, object: nil, userInfo: info)
            }

            task.resume()
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

protocol URLSessionProtocol {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    typealias APIError = URLSession.DataTaskPublisher.Failure
    func dataTaskPublisher(for url: URL) -> AnyPublisher<APIResponse, APIError>
}
extension URLSession: URLSessionProtocol {
    func dataTaskPublisher(for url: URL) -> AnyPublisher<APIResponse, APIError> {
        return URLSession.DataTaskPublisher(request: URLRequest(url: url), session: self).eraseToAnyPublisher()
    }
}
