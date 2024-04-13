//
//  CustomTableViewCell.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/12/24.
//

import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func didTapMapButton(cityName: String)
    func didTapWeatherButton(cityName: String)
}
class CustomTableViewCell: UITableViewCell {
    weak var delegate: CustomTableViewCellDelegate?
    
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!
    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
        if let cityName = cityNameLabel.text {
            delegate?.didTapMapButton(cityName: cityName)
        }
    }

    @IBAction func weatherButtonTapped(_ sender: UIButton) {
        if let cityName = cityNameLabel.text {
            delegate?.didTapWeatherButton(cityName: cityName)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
