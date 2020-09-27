//
//  FavoritesController.swift
//  Podcasts
//
//  Created by t19960804 on 9/5/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController {
    let headerID = "headerID"
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    var favoritePodcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView!.register(FavoritesCell.self, forCellWithReuseIdentifier: FavoritesCell.cellID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        collectionView.reloadData()
        tabBarItem.badgeValue = nil
    }
    //Notify the view controller that its view has just laid out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //在viewDidLayoutSubviews中,collectionView的長寬才會被決定,計算itemSize時才不會錯誤
        //https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/auto-layout-%E7%9A%84%E5%85%83%E4%BB%B6%E8%A9%B2%E5%9C%A8%E4%BD%95%E6%99%82%E8%A8%AD%E5%AE%9A%E5%9C%93%E8%A7%92%E7%9A%84-layer-cornerradius-669fae1c287c
        setupCollectionView()
    }
    fileprivate func setupCollectionView(){
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
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID, for: indexPath)
        let label = UILabel(text: "No favorite Pocast!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        header.addSubview(label)
        label.centerInSuperview()
        return header
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodeController = EpisodesController()
        episodeController.podcast = favoritePodcasts[indexPath.item]
        navigationController?.pushViewController(episodeController, animated: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension FavoritesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //若不給size,viewForSupplementaryElementOfKind就不會被呼叫
        let height: CGFloat = favoritePodcasts.isEmpty ? 250 : 0
        return .init(width: collectionView.frame.size.width, height: height)
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
