//
//  OnceTimer.swift
//  TimerCollection
//
//  Created by Tolga Taner on 14.11.2020.
//

import Foundation

public class OnceTimer: Schedule {
    public let identifier: String = UUID().uuidString
    public weak var delegate: ScheduleDelegate?
    public var timer: DispatchSourceTimer?
    public var state: State = .awaiting {
        didSet {
            if state == .finished  || state == .awaiting {
                passingTime = 0
            }
        }
    }
    public var period: Period
    public var tolerance: DispatchTimeInterval {
        .milliseconds(100)
    }
    private var repeating: DispatchTimeInterval {
        return .seconds(1)
    }

    private var deadline: DispatchTime {
        .now()
    }

    private var passingTime: TimeInterval = 0.0 {
        didSet {
            _time.passingTime = passingTime
        }
    }

    @TimeRepresentation(passingTime: 0.0, endTime: 0.0)
    private var time: String
    init(period: Period) {
        self.period = period
        _time = TimeRepresentation(passingTime: passingTime,
                                   endTime: period.timeInterval)

        timer = TimerCollection.get(identifier: identifier,
                                    deadline: deadline,
                                    repeating: repeating,
                                    tolerance: tolerance)
    }

    deinit {
        over()
        state = .awaiting
    }

    public func start() {
        if state == .running {
            return
        }
        state = .running
        delegate?.schedule(starting: self,
                           withIdentifier: identifier,
                           finishedOn: time)
        timer?.setEventHandler(handler: { [weak self] in
            guard let self = self else { return }
            self.update()
        })
        timer?.resume()
    }

    public func finish() {
        if state == .finished {
            return
        }
        state = .finished
        timer?.cancel()
    }

    public func stop() {
        if state == .awaiting || state == .finished {
            return
        }
        state = .suspended
        timer?.suspend()
    }

    public func resume() {
        if state == .awaiting || state == .finished {
            return
        }
        timer?.resume()
        over()
        timer = TimerCollection.get(identifier: identifier,
                                    deadline: deadline,
                                    repeating: repeating,
                                    tolerance: tolerance)
        start()
    }

    private func over() {
        timer?.cancel()
        timer?.setEventHandler(handler: nil)
        timer = nil
    }

    private func running() {
        passingTime += 1.0
    }

    private func update() {
        running()
        if isTimeUp() {
            delegate?.schedule(finished: self)
            finish()
            return
        }
        delegate?.schedule(passed: self,
                           remainingTime: time)
    }

    private func isTimeUp() -> Bool {
        period.timeInterval.isEqual(to: passingTime)
    }

}

extension OnceTimer: Equatable {

    public static func == (lhs: OnceTimer, rhs: OnceTimer) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
