//
//  ViewController.swift
//  MyYandexWeatherApp
//
//  Created by Антон Добровинский on 22/7/20.
//  Copyright © 2020 Антон Добровинский. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController { // тут не рефакторился код, надо быть внимательнее; возможно, дальше придётся с этим иметь дело
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLocationButtonTapped(_ sender: Any) {
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
    }
    
}

