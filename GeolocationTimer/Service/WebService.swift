//
//  WebService.swift
//  GeolocationTimer
//
//  Created by Anton Honcharenko on 09.07.2020.
//  Copyright © 2020 test. All rights reserved.
//

import Foundation

class WebService {
    static let shared = WebService()

    func sendGeolocation(sendModel: SendLocationModel, onSuccess: @escaping (Any) -> Void, onError: @escaping (Error?) -> Void) {
        let json: [String: Any] = ["time": sendModel.time, "lat": sendModel.latitude, "lon": sendModel.longitude]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://team24.biz/api/geo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                OperationQueue.main.addOperation {
                    onError(error)
                }
                return
            }
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                print(responseJSON)
                OperationQueue.main.addOperation {
                    onSuccess(responseJSON)
                }
            } catch {
                OperationQueue.main.addOperation {
                    onError(error)
                }
            }
        }
        task.resume()
    }
}
