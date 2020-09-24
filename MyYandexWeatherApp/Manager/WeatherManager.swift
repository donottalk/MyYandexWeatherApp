//
//  WeatherManager.swift
//  MyYandexWeatherApp
//
//  Created by Антон Добровинский on 23/7/20.
//  Copyright © 2020 Антон Добровинский. All rights reserved.
//

import Foundation
import Alamofire

enum WeatherError: Error, LocalizedError {
    
    case unknown
    case invalidCity
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Произошла неизвестная ошибка"
        case .invalidCity:
            return "Такого города нет в базе."
        case .custom(let description):
            return description
        }
    }
}

struct WeatherManager {
    
    private let API_KEY = "" // ключ от API openweathermap
        
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {

        let path = "http://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&lon=%f"
        
        let urlString = String(format: path, API_KEY, lat, lon)
        
        AF.request(urlString).validate().responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                
                let model = weatherData.model
                
                completion(.success(model))
                
            case .failure(let error):
                
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // ⌘⌘⌘
    
    func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        
        let path = "http://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        
        let urlString = String(format: path, query, API_KEY)
        
        AF.request(urlString).validate().responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                
                let model = weatherData.model
                
                completion(.success(model))
                
            case .failure(let error):
                
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: Функция показывающая различные статусы и сообщения, которые мы получаем от API; переменные можно заменить, соответственно, получить другие статусы
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        
        if error.responseCode == 404,
            let data = data,
            let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.custom(description: message)
            // MARK: сообщение об ошибке на английском тут от OpenWeather API
        } else {
            print("nil returned")
            return nil
        }
    }
}
