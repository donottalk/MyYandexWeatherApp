//
//  AddCityViewController.swift
//  MyYandexWeatherApp
//
//  Created by Антон Добровинский on 26/7/20.
//  Copyright © 2020 Антон Добровинский. All rights reserved.
//

import UIKit

class AddCityViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let weatherManager = WeatherManager()
    
    weak var delegate: WeatherViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityTextField.becomeFirstResponder()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        statusLabel.isHidden = true
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        statusLabel.isHidden = true
        guard let query = cityTextField.text, !query.isEmpty else {
            showSearchError(text: "Ничего не нашлось. Попробуйте ещё раз!")
            return }
        handleSearch(query: query)
    }
    
    private func showSearchError(text: String) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemRed
        statusLabel.text = text
    }
    
    private func handleSearch(query: String) {
        view.endEditing(true)
        activityIndicatorView.startAnimating()
        weatherManager.fetchWeather(byCity: query) { [weak self] (result) in
            guard let this = self else { return }
            this.activityIndicatorView.stopAnimating()
            switch result {
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                this.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemGreen
        statusLabel.text = "Загрузка…"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let this = self else { return }
            this.delegate?.didUpdateWeatherFromSearch(model: model)
        }
    }
}

extension AddCityViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}
