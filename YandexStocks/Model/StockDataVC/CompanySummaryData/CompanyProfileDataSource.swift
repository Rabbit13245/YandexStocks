//
//  CompanySummaryDataSource.swift
//  YandexStocks
//
//  Created by Дмитрий Зайцев on 28.03.2021.
//

import UIKit

class CompanyProfileDataSource: NSObject, UITableViewDataSource {
    var companyProfileData: CompanyProfileData?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyProfileData?.companyProfile.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CompanyProfileTableViewCell.self)) as? CompanyProfileTableViewCell else {
            return UITableViewCell()
        }
        
        guard let model = companyProfileData?.companyProfile[indexPath.row] else { return cell }
        cell.configure(with: model)
        return cell
    }
}
