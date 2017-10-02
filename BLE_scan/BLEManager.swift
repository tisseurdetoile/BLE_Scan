import CoreBluetooth
import Cocoa


class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager
    fileprivate var writeCompletionHandler: (() -> Void)?

    override init() {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        self.centralManager.delegate = self
    }

    // Required. Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        switch manager.state {
        case .poweredOff:
            print("BLE has powered off")
            centralManager.stopScan()
        case .poweredOn:
            print("BLE is now powered on")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .resetting: print("BLE is resetting")
        case .unauthorized: print("Unauthorized BLE state")
        case .unknown: print("Unknown BLE state")
        case .unsupported: print("This platform does not support BLE")
        }
    }

    // Invoked when the central manager discovers a peripheral while scanning.
    func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData advertisement: [String: Any], rssi: NSNumber) {

        let identifier = peripheral.value(forKey: "identifier") as! NSUUID as UUID
        var msg = "Device : \(identifier) - RSSI : \(rssi) "

        Logger.log(message: "identifier = >\(identifier)<", event: .i)

        if let name = peripheral.name {
            msg += "DeviceName : \(name) "
            Logger.log(message: "name = >\(name)<", event: .i)
        } else {
            Logger.log(message: "Device has no name", event: .i)
            if let serviceData = advertisement[CBAdvertisementDataServiceDataKey] as? [NSObject:AnyObject]{

                msg += "serviceData : \(serviceData) "
                Logger.log(message: "serviceData = >\(serviceData)<", event: .i)

                var eft: BeaconInfo.EddystoneFrameType
                eft = BeaconInfo.frameTypeForFrame(advertisementFrameList: serviceData)


                if eft == BeaconInfo.EddystoneFrameType.URLFrameType {
                    let serviceUUID = CBUUID(string: "FEAA")
                    let beaconServiceData = serviceData[serviceUUID] as! NSData
                    let readUrl = BeaconInfo.parseURLFromFrame(frameData: beaconServiceData)

                    msg += "EddyStoneUrl : \(readUrl!) "

                    //print ("UUID =", identifier, "url =", readUrl ?? "none", "rssi : ", rssi)
                }
            }
        }

        print (msg)
    }

    func startScan(completionHandler: (() -> Void)? = nil) {
        writeCompletionHandler = completionHandler
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
    }

}