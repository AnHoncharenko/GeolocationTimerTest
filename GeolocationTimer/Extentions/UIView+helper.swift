//
//  UIView+helper.swift
//  GeolocationTimer
//
//  Created by Anton Honcharenko on 09.07.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

func delay(_ interval: TimeInterval, _ action: @escaping () -> Void) {
    let item = DispatchWorkItem(block: action)
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: item)
}

extension UIView {
    func bampAnimation(scaleX: CGFloat = 1.15, scaleY: CGFloat = 1.15, duration: TimeInterval = 0.15) {
        UIView.animate(withDuration: duration, animations: { self.transform = .init(scaleX: scaleX, y: scaleY) })
        delay(duration, { UIView.animate(withDuration: duration, animations: { self.transform = .identity }) })
    }
}
