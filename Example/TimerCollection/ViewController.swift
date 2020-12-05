//
//  ViewController.swift
//  TimerCollection
//
//  Created by tolgataner on 12/05/2020.
//  Copyright (c) 2020 tolgataner. All rights reserved.
//

import UIKit
import TimerCollection

class ViewController: UIViewController {

    var collection:TimerCollection!
    override func viewDidLoad() {
        super.viewDidLoad()
        collection = TimerCollection(periods: .countdown(once: 10))
        collection.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ViewController: TimerCollectionDelegate {
    
    func timerCollection(schedule: Schedule, willFinishAfter current: String) {

    }

    func timerCollection(finished schedule: Schedule) {

    }


}
