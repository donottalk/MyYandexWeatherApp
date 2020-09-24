//
//  ViewController.swift
//  MyYandexWeatherApp
//
//  Created by Антон Добровинский on 22/7/20.
//  Copyright © 2020 Антон Добровинский. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

protocol WeatherViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController { // MARK: тут не рефакторился код, надо быть внимательнее: возможно, дальше придётся с этим иметь дело;
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeather(byCity: "Minsk")
    }
    
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in // MARK: Здесь девятки
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        hideAnimation()
        conditionImageView.image = UIImage(named: "imSad")
        navigationItem.title = ""
        temperatureLabel.text = "Ой!"
        conditionLabel.text = "Что-то пошло не так.\nПопробуйте снова.\nЧерез минутку."
        Loaf(error.localizedDescription, state: .error, location: .bottom, sender: self).show()
    }
    
    private func fetchWeather(byCity city: String) {
        showAnimation()
        weatherManager.fetchWeather(byCity: city) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func updateView(with model: WeatherModel) {
        hideAnimation()
        temperatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        navigationItem.title = model.countryName
        conditionImageView.image = UIImage (named: model.conditionImage)
    }
    
    private func hideAnimation() {
        conditionImageView.hideSkeleton()
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    
    private func showAnimation() {
        conditionImageView.showAnimatedGradientSkeleton() // MARK: отменная фишка из библиотеки SkeletonView с анимацией элементов предзагрузки
        temperatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
    }
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            locationManager.requestLocation()
        default:
            promptForLocationPermission()
        }
    }
    
    private func promptForLocationPermission() {
        
        let alertController = UIAlertController(title: "Нужно разрешить геолокацию", message: "Можем перейти в Настройки и дать приложению доступ к геолокации", preferredStyle: .alert)
        
        let enableAction = UIAlertAction(title: "Перейти в Настройки", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension WeatherViewController: WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.updateView(with: model)
        })
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            fetchWeather(byLocation: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
}
