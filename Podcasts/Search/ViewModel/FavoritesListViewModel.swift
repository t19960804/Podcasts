//
//  FavoritesListViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/21/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import UIKit

class FavoritesListViewModel {
    var isDeleting = false
    var favoritePodcasts = [Podcast]() {
        didSet {
            if isDeleting == false { //刪除Item時不需要做事,否則會報錯
                favoritePodcasts.reverse()
                reloadController?()
            }
        }
    }
    var reloadController: (() -> ())?
    
    //HeightForHeader
    func calculateHeightForHeader() -> CGFloat {
        let height: CGFloat = favoritePodcasts.isEmpty ? 250 : 0
        return height
    }
}
