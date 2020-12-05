//
//  TimeRepresentation.swift
//  TimerCollection
//
//  Created by Tolga Taner on 27.11.2020.
//

import Foundation

@propertyWrapper
struct TimeRepresentation {

    private lazy var formatter: DateComponentsFormatter = {
        let formatter: DateComponentsFormatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var wrappedValue: String
    var passingTime: TimeInterval {
        didSet {
            wrappedValue = formatter.string(from: endTime - passingTime) ?? "0:0"
        }
    }
    let endTime: TimeInterval

    init(passingTime: TimeInterval,
         endTime: TimeInterval) {
        defer { self.passingTime = passingTime}
        self.passingTime = passingTime
        self.endTime = endTime
        wrappedValue = "0:0"
    }
}
