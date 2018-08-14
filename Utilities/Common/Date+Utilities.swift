//
//  Date+Utilities.swift
//  Entrada
//
//  Created by Muthuraj Muthulingam on 02/08/18.
//  Copyright © 2018 Entrada, Inc. All rights reserved.
//

import Foundation

enum DateFormat: String {
    case dateHourMinSec = "yyyy-MM-dd-HH-mm-ss"
    case timeDetails = "HH-mm-ss"
    case date = "yyyy-MM-dd"
    case hourMin = "HH-mm"
    case dateHourMin = "yyyy-MM-dd-HH-mm"
}

extension DateFormatter {
    func currentDateString(dateFormat: DateFormat) -> String {
        self.dateFormat = dateFormat.rawValue
        return string(from: Date())
    }
}

extension Date {
    func epoch() -> TimeInterval {
        return timeIntervalSince1970
    }
}
