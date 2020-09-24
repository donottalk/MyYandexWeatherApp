//
//  Double+Extension.swift
//  MyYandexWeatherApp
//
//  Created by Антон Добровинский on 26/7/20.
//  Copyright © 2020 Антон Добровинский. All rights reserved.
//

import Foundation

extension Double {
    func toString() -> String {
        return String(format: "%.1f", self)
    }
    
    func toInt() -> Int {
        return Int(self)
    }
}

// экстэншн, который возвращает строку из Double без сотых значений
// Примененение — data.main.temp.toString().appending("°C")
