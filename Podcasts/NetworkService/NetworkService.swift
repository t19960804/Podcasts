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
import UIKit

//為何不用struct來設計Singleton?
//因為struct為value type,代表其他人對於Singleton的操作可能不會反映到Singleton
//這樣就違反了Singleton的唯一性,因為每個人看到的Singleton的狀態都不一致
class NetworkService: NSObject {
    
    static let sharedInstance = NetworkService()
    private var session: URLSessionProtocol = URLSession.shared
    private var downlodingEpisode: EpisodeCellViewModel?

    //URLSession for background download
    private lazy var backgroundUrlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.sessionSendsLaunchEvents = true
        //Provide a delegate, to receive events from the background transfer.
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private override init(){
        
    }
    func replaceSession(with session: URLSessionProtocol){
        self.session = session
    }
    func fetchData(url: URL) -> AnyPublisher<Data, Never> {
        let publisher = session.dataTaskPublisher(for: url)
        return publisher
            .map { $0.data }
            .replaceError(with: Data()) //將Error替換成其他element
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func fetchPodcasts(searchText: String) -> AnyPublisher<SearchResult, Error> {
        if searchText.isEmpty {
            let result = SearchResult(resultCount: 0, results: [])
            let publisher = Just(result)//Just produces Never, not Error
            return publisher
                .setFailureType(to: Error.self)//set the error type of a publisher that cannot fail.
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
    private var xmlParser: RSSFeedParseProtocol?
    func fetchEpisodes(parser: RSSFeedParseProtocol) -> Future<[Episode],Error> {
        self.xmlParser = parser
        return Future() { promise in
            DispatchQueue.global(qos: .background).async {
                self.xmlParser?.parse { (result) in
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
    func downloadEpisode(with episode: EpisodeCellViewModel) {
        guard let url = episode.audioUrl else {
            print("Error - AudioUrl has some problem")
            return
        }
        downlodingEpisode = episode
        let task = backgroundUrlSession.downloadTask(with: url)
        task.countOfBytesClientExpectsToSend = 200 // 最大上傳200Byte
        task.countOfBytesClientExpectsToReceive = 500 * 1024 // 最大下載500KB
        task.resume()
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
protocol RSSFeedParseProtocol {
    func parse(result: @escaping (Result<Feed, ParserError>) -> Void)
}
extension FeedParser: RSSFeedParseProtocol {
    func parse(result: @escaping (Result<Feed, ParserError>) -> Void) {
        self.parseAsync(result: result)
    }
}


extension NetworkService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("the file is fully downloaded:\(location)")
        do {
            //載下來的data會存在.tmp檔,需要將data取出寫成.mp3檔
            //https://stackoverflow.com/questions/50383343/urlsession-download-from-remote-url-fail-cfnetworkdownload-gn6wzc-tmp-appeared
            let data = try Data(contentsOf: location)
            let pathOfDocument = FileManager.default.documentsFolderURL
            let url = pathOfDocument.appendingPathComponent("\(downlodingEpisode!.title).mp3")
            //https://cdfq152313.github.io/post/2016-10-11/
            try! data.write(to: url)
            //更新Userdefaults並發送通知
            var downloadEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
            if let index = downloadEpisodes.firstIndex(where: {
                $0.title == downlodingEpisode!.title && $0.author == downlodingEpisode!.author
            }) {
                downloadEpisodes[index].fileUrl = url
                downloadEpisodes[index].isWaitingForDownload = false
            }
            UserDefaults.standard.saveDownloadEpisode(with: downloadEpisodes)
            let info = [Notification.episodeKey : downlodingEpisode!]
            NotificationCenter.default.post(name: .episodeDownloadDone, object: nil, userInfo: info)
        } catch {
            print("Err - Get data from tmpFile url failed")
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData byteWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let info: [String : Any] = [
            Notification.progressKey : Int(progress * 100),
            Notification.episodeKey : downlodingEpisode!
        ]
        NotificationCenter.default.post(name: .progressUpdate, object: nil, userInfo: info)
    }
}
extension NetworkService: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { //urlSessionDidFinishEvents(forBackgroundURLSession:)有可能會在back ground thread執行,所以要切換到main thread
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let backgroundCompletionHandler =
                appDelegate.backgroundCompletionHandler else {
                    return
            }
            backgroundCompletionHandler()
        }
    }
}
