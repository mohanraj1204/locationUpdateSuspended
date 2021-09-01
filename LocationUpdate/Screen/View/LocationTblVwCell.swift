//
//  LocationTblVwCell.swift
//  LocationUpdate
//
//  Created by Mohanraj on 01/09/21.
//

import UIKit

class LocationTblVwCell: UITableViewCell {

    @IBOutlet var latitude: UILabel!
    @IBOutlet var longitude: UILabel!
    @IBOutlet var time: UILabel!
    
    
    static let CellIdentifier = "LocationTblVwCell"
    static let NibName = "LocationTblVwCell"

    
    private var index: Int?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension LocationTblVwCell {
    func configure(with cellViewModel : LocationListCellViewModel, at index :Int) {
        self.index = index
        latitude.text = cellViewModel.latitude
        longitude.text = cellViewModel.longitude
        time.text = cellViewModel.time
    }
}
