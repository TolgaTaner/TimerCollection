//
//  RepeatableTimer.swift
//  TimerCollection
//
//  Created by Tolga Taner on 14.11.2020.
//

import Foundation

public class RepeatableTimer: Schedule {

    public let identifier: String = UUID().uuidString
    public weak var delegate: ScheduleDelegate?
    var period: Period
    public var state: State = .awaiting

    public var timer: DispatchSourceTimer?

    public var tolerance: DispatchTimeInterval {
        .milliseconds(100)
    }

    private var deadline: DispatchTime {
        .now() + repeating
    }

    private var repeating: DispatchTimeInterval {
        return period.get()
    }

    deinit {
        over()
        state = .awaiting
    }

    init(period: Period) {
        self.period = period
        timer = TimerCollection.get(identifier: identifier,
                                    deadline: deadline,
                                    repeating: repeating,
                                    tolerance: tolerance)
    }

    public func start() {
        if state == .running {
            return
        }
        state = .running
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

    func resume() {
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

    private func update() {
        delegate?.schedule(finished: self)
    }

}
