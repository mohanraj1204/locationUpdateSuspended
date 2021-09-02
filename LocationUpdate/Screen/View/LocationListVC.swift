//
//  LocationListVC.swift
//  LocationUpdate
//
//  Created by Mohanraj on 01/09/21.
//

import UIKit
import Foundation
import CoreLocation

class LocationListVC: UIViewController {

    static let NibName = "LocationListVC"
    var viewModel : LocationViewModel = LocationViewModelImpl()

    @IBOutlet var tblVw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        appDelegate?.locationManager?.requestAlwaysAuthorization()
    }
}

// MARK: - UserDefined Method

extension LocationListVC {
    private func initialSetup() {
        self.title = viewModel.title
        self.registerTblVwCell();
        self.addNotificationObserver()
        self.loadData()
    }
    
    private func addNotificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func registerTblVwCell(){
        self.tblVw.register(UINib(nibName: LocationTblVwCell.NibName, bundle: nil), forCellReuseIdentifier: LocationTblVwCell.CellIdentifier)
        self.tblVw.tableFooterView = UIView()
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
    }
    
    private func loadData(){
        viewModel.getLocationListLocalDB { [weak self] in
            self?.tblVw.reloadData()
        } failed: {
            print("Failed")
        }
    }
    
}

// MARK: - Call Back
extension LocationListVC {
    @objc func willEnterForeground() {
        self.loadData()
    }
}

// MARK: - UITableView Delegate And Datasource Methods
extension LocationListVC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locatioListCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTblVwCell.CellIdentifier) as? LocationTblVwCell else{
            return UITableViewCell()
        }
        if let cellVM  = viewModel.cellViewModelForLocationList(at: indexPath.row){
            cell.configure(with: cellVM, at: indexPath.row)
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
