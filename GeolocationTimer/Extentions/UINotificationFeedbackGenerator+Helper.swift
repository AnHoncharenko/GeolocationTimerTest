//
//  UINotificationFeedbackGenerator+Helper.swift
//  GeolocationTimer
//
//  Created by Anton Honcharenko on 09.07.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

extension UINotificationFeedbackGenerator {
    func safePrepare() {
        DispatchQueue.main.async {
            self.prepare()
        }
    }

    func safeNotificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            self.notificationOccurred(type)
        }
    }
}
