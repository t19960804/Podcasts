//
//  EpisodePlayerController.swift
//  Podcasts
//
//  Created by t19960804 on 5/1/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class EpisodePlayerController: UIViewController {
    var episode: Episode! {
        didSet {
            let urlString = episode.imageURL
            let url = URL(string: urlString ?? "")
            episodeImageView.sd_setImage(with: url)
            titleLabel.text = episode.title
        }
    }
    lazy var dismissButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Dismiss", for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        btn.setTitleColor(.blue, for: .normal)
        btn.backgroundColor = .red
        return btn
    }()
    let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    let playerSlider: UISlider = {
        let sd = UISlider()
        sd.backgroundColor = .brown
        return sd
    }()
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Title"
        lb.textAlignment = .center
        lb.backgroundColor = .orange
        return lb
    }()
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dismissButton,
                                                episodeImageView,
                                                playerSlider,
                                                titleLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        return sv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpConstraints()
    }
    func setUpConstraints(){
        view.addSubview(vStackView)
        vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        vStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        vStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        episodeImageView.heightAnchor.constraint(equalTo: episodeImageView.widthAnchor, multiplier: 1).isActive = true
    }
    @objc fileprivate func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}
