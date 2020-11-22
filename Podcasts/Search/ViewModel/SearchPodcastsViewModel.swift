//
//  SearchPodcastsViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/15/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import UIKit

//ViewModel的職責就是讓ViewController或是View變得更乾淨
//不然邏輯混合在ViewController的生命週期,或是跟View混在一起,就不好測試了
//ViewModel中會有兩種邏輯
//1.Presentation Logic > 跟View相關的邏輯
//2.Controller Logic > 跟View無關的邏輯(Fetch API / FileManager)
class SearchPodcastsViewModel {
    //用Binding實作Reactive Programming
    //Fetch Data
    var isSearching = false {
        didSet {
            isSearchingObserver?(isSearching)
        }
    }
    var podcasts = [Podcast]() {
        didSet {
           reloadController?(podcasts)
        }
    }
    var isSearchingObserver: ((Bool) -> ())?
    var reloadController: (([Podcast]) -> ())?
    
    func fetchPodcasts(searchText: String){
        isSearching = true
        podcasts = []
        
        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
            switch result {
            case .failure(let error):
                print("Request data failed:\(error)")
                self.podcasts = []
            case .success(let podcasts):
                self.podcasts = podcasts
            }
            self.isSearching = false
        }
    }
    //SearchBar
    var headerLabelString = ""
    func searchBarInputUpdate(input: String){
        headerLabelString = input.isEmpty ? "Please enter a search query" : "There is no podcast about: \(input)"
    }
    //HeightForHeader
    func calculateHeightForHeader() -> CGFloat {
        if isSearching == false && podcasts.isEmpty {
             return 250//Searching完且沒有任何結果,秀出Header,並根據使用者有無輸入顯示不同內容
        } else {
            return 0
        }
    }
}
