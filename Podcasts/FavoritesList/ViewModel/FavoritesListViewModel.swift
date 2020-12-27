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
    var favoritePodcasts = [FavoritedPodcast]()
    
    //HeightForHeader
    func calculateHeightForHeader() -> CGFloat {
        let height: CGFloat = favoritePodcasts.isEmpty ? 250 : 0
        return height
    }
}
