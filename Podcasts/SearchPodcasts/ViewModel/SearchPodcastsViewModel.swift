//
//  SearchPodcastsViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/15/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import Combine

class SearchPodcastsViewModel {
    //Fetch Data
    //讓Property變成Publisher
    @Published var isSearching = false
    @Published var podcasts = [Podcast]()
    private var fetchPodcastsSubscriber: AnyCancellable?
    
    func fetchPodcasts(searchText: String){
        isSearching = true
        podcasts = []
        let publisher = NetworkService.sharedInstance.fetchPodcasts(searchText: searchText)
        fetchPodcastsSubscriber = publisher
            .map(\.results)
            //.mapError > 將Error轉換成其他類型的Error
            //.map > 轉換每個element
            //.catch > 捕捉到Error時回傳預設值
            //Just > init from a value then provides a single result (no error)
            .catch { (error) -> Just<[Podcast]> in
                print("Err - Fetch podcasts failed: \(error.localizedDescription)")
                return Just([])
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [unowned self] podcasts in
                    self.podcasts = podcasts
                    self.isSearching = false
            })
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
