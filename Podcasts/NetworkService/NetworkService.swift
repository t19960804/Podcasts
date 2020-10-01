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

class NetworkService {
    static let sharedInstance = NetworkService() //static > 由於其他類別沒辦法初始化NetworkService,所以讓其他類別不需要初始化即可使用屬性
    
    private init(){//private > 防範其他的類別來初始化
        
    }
    //@escaping > 讓closure在function執行完後可以呼叫(逃離function的生命週期)
    //由於@escaping的closure被呼叫時需要存取到變數 / 常數 / 函式,所以需要加上self.xxx
    //讓self的Reference count + 1,保證closure被呼叫前self不會被釋放掉
    //https://www.jianshu.com/p/9fb444e88d26
    //https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/%E8%AE%93-closure-%E5%9C%A8-function-%E5%A4%96%E7%B9%BC%E7%BA%8C%E4%BD%BF%E7%94%A8%E7%9A%84-escaping-40d50b17f75b
    
    func fetchPodcasts(searchText: String, completion: @escaping (Result<[Podcast],Error>) -> Void){
        //requst url 範例: https://itunes.apple.com/search?term=jack+johnson&media=music
        let url = "https://itunes.apple.com/search"
        let extraParameters = ["term" : searchText,
                               "media" : "podcast"]
        //若輸入帶有空格的字串,會導致request失敗,須透過url encoding將"空格"轉換成"+"
        //例如: Brian Voong > Brian+Voong
        AF.request(url, method: .get, parameters: extraParameters, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (response) in
            if let error = response.error {
                completion(.failure(error))
                return
            }
            guard let data = response.data else {
                print("Request successly,but data has some problem")
                return
            }
            do {
                //Transform JSON data to model object
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(searchResult.results))
            } catch {
                completion(.failure(error))
            }
        }
    }
    func fetchEpisodes(url: URL, completion: @escaping (Result<[Episode],Error>) -> Void){
        //Qos > 執行任務的優先順序,等級越高越快被執行
        //userInteractive > userInitiated > `default` > utility > background > unspecified
        DispatchQueue.global(qos: .background).async {
            let xmlParser = FeedParser(URL: url)//Parser會在Main Thread執行所以會造成UI卡頓
            xmlParser.parseAsync { (result) in
                //Associated Value > 把值夾帶在enum case中
                //https://hugolu.gitbooks.io/learn-swift/content/Advanced/Enum.html#associated_value
                switch result {
                case .success(let feed):
                    //RSS > 以XML為基礎的內容傳送機制
                    //Feed > 資料來源
                    guard let rssFeed = feed.rssFeed else {
                        print("Error - rssFeed is nil")
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
    func downloadEpisode(with episodeViewModel: EpisodeViewModel){
        guard let url = episodeViewModel.audioUrl else {
            print("Error - AudioUrl has some problem")
            return
        }
        //Download episode to FileManager
        let destination = DownloadRequest.suggestedDownloadDestination()

        print("Downloading from:\(episodeViewModel.audioUrl)")
        AF.download(url, to: destination)
                .downloadProgress { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                }
                .response { (response) in
                    print("Download file done,file at:\(response.fileURL)")
                    //下載完需要更新剛剛存進Userdefaults的episodeViewModel資訊
                    var downloadEpisodes = UserDefaults.standard.fetchDownloadedEpisode()
                    if let index = downloadEpisodes.firstIndex(where: {
                        $0.title == episodeViewModel.title && $0.author == episodeViewModel.author
                    }) {
                        downloadEpisodes[index].fileUrl = response.fileURL
                        print("Update fileUrl success")
                    }
                    UserDefaults.standard.saveDownloadEpisode(with: downloadEpisodes)
                }
    }
}

//Closure跟Function差別
//1.有無名字 > Closure沒有,Function有
//2.能否獨立存在 > Closure需要被指派到變數或常數,或直接傳入Function,但Function可獨立存在
//備註:兩個都能被指派到變/常數中


//@escaping > 讓 closure 在 function 外繼續使用 (將傳進的closure指派給外部的變數供呼叫)
