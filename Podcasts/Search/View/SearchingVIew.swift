//
//  SearchingVIew.swift
//  Podcasts
//
//  Created by t19960804 on 6/20/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class SearchingView: UIView {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let av = UIActivityIndicatorView(style: .whiteLarge)
        av.color = .purple
        av.translatesAutoresizingMaskIntoConstraints = false
        av.startAnimating()
        return av
    }()
    let searchingLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Currently Searching"
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .purple
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(activityIndicatorView)
        addSubview(searchingLabel)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        searchingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        searchingLabel.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
