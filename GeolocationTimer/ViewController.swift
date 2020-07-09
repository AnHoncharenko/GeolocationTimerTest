//
//  ViewController.swift
//  GeolocationTimer
//
//  Created by Anton Honcharenko on 09.07.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var writeTimeTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var timer: Timer?
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    private let feedback = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        timerLabel.text = "Enter from 1 to 10 minutes below"
        locManager.requestWhenInUseAuthorization()
        writeTimeTextField.delegate = self
        isTimerActive(false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc func didBecomeActiveNotification() {
        if checkLocationPrivacy() {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        view.endEditing(true)
    }

    @IBAction func onTextChange(_ sender: Any) {
        guard let time = writeTimeTextField.text else { return }
        if time.isEmpty {
            timerLabel.text = "Enter from 1 to 10 minutes below"
            return
        }
        timerLabel.text = writeTimeTextField.text
        if Int(time) ?? 0 > 10 {
            timerLabel.text = "10 is max"
            writeTimeTextField.text = "10"
        }
    }

    @IBAction func onStartButtonPress(_ sender: Any) {
        timer?.invalidate()
        guard let time = writeTimeTextField.text else { return }
        if time.isEmpty {
            writeTimeTextField.bampAnimation()
            return
        }
        guard let interval = Double(time) else { return }
        isTimerActive(true)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            let sendModel = self.createSendForm()
            WebService.shared.sendGeolocation(sendModel: sendModel,
                                              onSuccess: { _ in self.feedback.safeNotificationOccurred(.success) },
                                              onError: { _ in self.feedback.safeNotificationOccurred(.error) })
        })
    }

    @IBAction func onStopButtonPress(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        isTimerActive(false)
    }

    private func isTimerActive(_ flag: Bool) {
        stopButton.backgroundColor = flag ? .systemRed : .lightGray
        stopButton.isUserInteractionEnabled = flag
        startButton.backgroundColor = flag ? .lightGray : .systemGreen
        startButton.isUserInteractionEnabled = !flag
    }

    private func allowSharingLocationAlert() {
        let openSettingsAlert = UIAlertController(title: "Attention", message: "Allow sharing geolocation", preferredStyle: .alert)
        openSettingsAlert.addAction(.init(title: ("Allow in settings"), style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl)
            openSettingsAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(openSettingsAlert, animated: true, completion: nil)
    }

    private func checkLocationPrivacy() -> Bool {
        return(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)
    }

    private func createSendForm() -> SendLocationModel {
        let nowTime = Double(Date().timeIntervalSince1970)
        var latitude: Double = 0
        var longitude: Double = 0
        if checkLocationPrivacy() {
            if let currentLocation = locManager.location {
                latitude = currentLocation.coordinate.latitude
                longitude = currentLocation.coordinate.longitude
            }
        } else {
            allowSharingLocationAlert()
        }
        return SendLocationModel(time: nowTime, latitude: latitude, longitude: longitude)
    }
}

extension ViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 2
    }
}


