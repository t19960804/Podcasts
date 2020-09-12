//
//  FavoritesController.swift
//  Podcasts
//
//  Created by t19960804 on 9/5/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController {
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    var favoritePodcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts() ?? []
        collectionView.reloadData()
    }
    fileprivate func setupCollectionView(){
        collectionView.backgroundColor = .white
        collectionView!.register(FavoritesCell.self, forCellWithReuseIdentifier: FavoritesCell.cellID)
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        let remainWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing
        let numberOfItemInRow: CGFloat = 2
        layout.itemSize = .init(width: remainWidth / numberOfItemInRow , height: 0.31 * collectionView.frame.height)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritePodcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCell.cellID, for: indexPath) as! FavoritesCell
        cell.podcast = favoritePodcasts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FavoritesController: FavoritesCellDelegate {
    func longPressOnFavoritesCell(cell: UICollectionViewCell) {
        //計算long press在哪個podcast
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.favoritePodcasts.remove(at: indexPath.item)
            //https://stackoverflow.com/questions/46140824/invalid-update-invalid-number-of-items-in-section-0
            self.collectionView.deleteItems(at: [indexPath])//比.reloadData()多了動畫
            UserDefaults.standard.saveFavoritePodcast(with: self.favoritePodcasts)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
