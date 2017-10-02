//
// Created by TisseurDeToile on 01/10/2017.
// Copyright (c) 2017 TISSEURDETOILE. All rights reserved.
//

import Foundation

class Scanner {
    var bluetoothManager = BLEManager()
    var running = false

    func scan() {
        running = true
        let sem = DispatchSemaphore.init(value: 0);


        bluetoothManager.startScan(completionHandler: {
            sem.signal()
        })

        sem.wait()

    }
}