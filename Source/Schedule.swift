//
//  Timeable.swift
//  TimerCollection
//
//  Created by Tolga Taner on 14.11.2020.
//

import Foundation

public protocol Schedule {
    var identifier: String { get }
    var timer: DispatchSourceTimer? { get set }
    var state: State { get set }
    var tolerance: DispatchTimeInterval { get }
    var delegate: ScheduleDelegate? { get set }
    func start()
    func stop()
    func finish()
}

public protocol ScheduleDelegate: class {
    func schedule(starting schedule: Schedule,
                  withIdentifier identifier: String,
                  finishedOn time: String)
    func schedule(passed schedule: Schedule,
                  remainingTime time: String)
    func schedule(finished schedule: Schedule)
}

extension ScheduleDelegate {
    func schedule(passed schedule: Schedule,
                  remainingTime time: String) { }
}

 public enum State {

    case awaiting
    case running
    case suspended
    case finished

}
