//
//  NetworkService.swift
//  Podcasts
//
//  Created by t19960804 on 3/21/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
    static let sharedInstance = NetworkService()
    
    private init(){
        
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
                //將json data轉換成自訂類別
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(searchResult.results)
            } catch {
                print("Decode json failed:\(error)")
            }
        }
    }
}

//Closure跟Function差別
//1.有無名字 > Closure沒有,Function有
//2.能否獨立存在 > Closure需要被指派到變數或常數,或直接傳入Function,但Function可獨立存在
//備註:兩個都能被指派到變/常數中
