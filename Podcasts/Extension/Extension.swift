//
//  Extension.swift
//  Podcasts
//
//  Created by t19960804 on 4/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

extension UITableView {
    func eliminateExtraSeparators(){
        //清除tableView多餘的分隔線(若設定.separatorStyle = .none會導致cell之間的分隔線完全消失)
        //https://stackoverflow.com/questions/1369831/eliminate-extra-separators-below-uitableview
        self.tableFooterView = UIView()
    }
}
