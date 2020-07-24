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
    
    //requst url 範例: https://itunes.apple.com/search?term=jack+johnson&media=music
    func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> Void){
        let url = "https://itunes.apple.com/search"
        let extraParameters = ["term" : searchText,
                               "media" : "podcast"]
        //若輸入帶有空格的字串,會導致request失敗,須透過url encoding將"空格"轉換成"+"
        //例如: Brian Voong > Brian+Voong
        AF.request(url, method: .get, parameters: extraParameters, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (response) in
            if let error = response.error {
                print("Request failed:\(error)")
                return
            }
            guard let data = response.data else {
                print("Request successly,but data has some problem")
                return
            }
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(searchResult.results)
            } catch {
                print("Decode json failed:\(error)")
            }
        }
    }
    func fetchEpisodes(url: URL, completion: @escaping ([Episode]) -> Void){
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
                    completion(episodes)
                case .failure(let error):
                    print("Error - Parse XML failed:\(error)")
                }
            }
        }

    }
}

//Closure跟Function差別
//1.有無名字 > Closure沒有,Function有
//2.能否獨立存在 > Closure需要被指派到變數或常數,或直接傳入Function,但Function可獨立存在
//備註:兩個都能被指派到變/常數中


//@escaping > 讓 closure 在 function 外繼續使用 (將傳進的closure指派給外部的變數供呼叫)
