//
//  TimerCollection.swift
//  TimerCollection
//
//  Created by Tolga Taner on 14.11.2020.
//

import Foundation

public enum Period {
    case countdown(once: TimeInterval)
    case repeated(interval: TimeInterval)
    func get() -> DispatchTimeInterval {
        switch self {
        case .countdown(let once):
            return .seconds(Int(once))
        case .repeated(let interval):
            return .seconds(Int(interval))
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .countdown(once: let once): return once.rounded()
        case .repeated(interval: let interval): return interval.rounded()
        }
    }

}

public protocol TimerCollectionDelegate: class {

    func timerCollection(schedule: Schedule,
                         willFinishAfter time: String)
    func timerCollection(finished schedule: Schedule)

}

open class TimerCollection {

    public weak var delegate: TimerCollectionDelegate?
    private lazy var collection: [String: Schedule] = [:]
    private let queue: DispatchQueue = DispatchQueue(label: "collection.queue",
                                                     attributes: .concurrent)

    deinit {
        collection.removeAll()
    }

    public init( periods: Period...) {
        periods.forEach {
            add(period: $0)
        }
    }

    open func start() {
        queue.sync { [weak self] in
            guard let self = self else { return }
            self.collection.lazy.forEach { $0.value.start() }
        }
    }

    open func add( period: Period) {
        switch period {
        case .countdown:
            let timer: OnceTimer = OnceTimer(period: period)
            timer.delegate = self
            collection[timer.identifier] = timer
        case .repeated:
            let timer = RepeatableTimer(period: period)
            timer.delegate = self
            collection[timer.identifier] = timer
        }
    }

    open func reset() {
        collection.forEach {
            $0.value.finish()
        }
        collection.removeAll()
    }
    static func get(identifier: String,
                    deadline: DispatchTime,
                    repeating: DispatchTimeInterval,
                    tolerance: DispatchTimeInterval) -> DispatchSourceTimer {
       let timer: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.TimerCollection-\(identifier).queue"))
       timer.schedule(deadline: deadline,
                      repeating: repeating,
                      leeway: tolerance)
       return timer
   }
}

extension TimerCollection: ScheduleDelegate {

    public func schedule(starting schedule: Schedule,
                  withIdentifier identifier: String,
                  finishedOn time: String) {
        delegate?.timerCollection(schedule: schedule,
                                  willFinishAfter: time)
    }

    public func schedule(finished schedule: Schedule) {
        collection.removeValue(forKey: schedule.identifier)
        delegate?.timerCollection(finished: schedule)
    }

    public func schedule(passed schedule: Schedule,
                  remainingTime time: String) {
        delegate?.timerCollection(schedule: schedule,
                                  willFinishAfter: time)

    }

}
