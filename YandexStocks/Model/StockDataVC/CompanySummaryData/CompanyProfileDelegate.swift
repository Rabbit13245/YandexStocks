//
//  CompanySummaryDelegate.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit

class CompanyProfileDelegate: NSObject, UITableViewDelegate {
    var companyProfileData: CompanyProfileData?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = companyProfileData?.companyProfile[indexPath.row] else { return }
        switch data.0 {
        case "Web":
            guard let url = URL(string: data.1) else { return }
            UIApplication.shared.open(url)
        case "Phone":
            guard let url = URL(string: "tel://\(data.1)") else { return }
            UIApplication.shared.open(url)
        default:
            return
        }
    }
}
