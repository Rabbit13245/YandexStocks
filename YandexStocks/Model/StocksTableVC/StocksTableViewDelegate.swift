//
//  StocksTableViewDelegate.swift
//  YandexStocks
//
//  Created by Admin on 3/23/21.
//

import UIKit

class StocksTableViewDelegate: NSObject, UITableViewDelegate {
    
    var headerView: UIView?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
