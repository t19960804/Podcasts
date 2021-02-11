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
            //mapError > Converts any failure from the upstream publisher into a new error.
            //Return a publisher that replaces any upstream failure with a new error
            //map > 轉換每個element
            .mapError { [unowned self] (error) -> Error in // 有error就不會到.sink
                print("Err - Fetch podcasts failed: \(error.localizedDescription)")
                self.podcasts = []
                self.isSearching = false
                return error
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
