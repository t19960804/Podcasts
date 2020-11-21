//
//  FavoritesController.swift
//  Podcasts
//
//  Created by t19960804 on 9/5/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class FavoritesListController: UICollectionViewController {
    let headerID = "headerID"
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    let viewModel = FavoritesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        viewModel.reloadController = {
            self.collectionView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        tabBarItem.badgeValue = nil
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //在viewDidLayoutSubviews中,collectionView的長寬才會被決定,計算itemSize時才不會錯誤
        calculateItemSize()
    }
    fileprivate func setupCollectionView(){
        collectionView.backgroundColor = .white
        collectionView!.register(FavoritesCell.self, forCellWithReuseIdentifier: FavoritesCell.cellID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
    }
    fileprivate func calculateItemSize(){
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        let remainWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing
        let numberOfItemInRow: CGFloat = 2
        layout.itemSize = .init(width: remainWidth / numberOfItemInRow , height: 0.31 * collectionView.frame.height)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoritePodcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCell.cellID, for: indexPath) as! FavoritesCell
        cell.podcast = viewModel.favoritePodcasts[indexPath.item]
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
        episodeController.podcast = viewModel.favoritePodcasts[indexPath.item]
        navigationController?.pushViewController(episodeController, animated: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension FavoritesListController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //若不給size,viewForSupplementaryElementOfKind就不會被呼叫
        let height = viewModel.calculateHeightForHeader()
        return .init(width: collectionView.frame.size.width, height: height)
    }
}
extension FavoritesListController: FavoritesCellDelegate {
    func longPressOnFavoritesCell(cell: UICollectionViewCell) {
        //計算long press在哪個podcast
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (_) in
            viewModel.isDeleting = true
            viewModel.favoritePodcasts.remove(at: indexPath.item)
            //https://stackoverflow.com/questions/46140824/invalid-update-invalid-number-of-items-in-section-0
            collectionView.deleteItems(at: [indexPath])//比.reloadData()多了動畫
            UserDefaults.standard.saveFavoritePodcast(with: viewModel.favoritePodcasts)
            viewModel.isDeleting = false
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
