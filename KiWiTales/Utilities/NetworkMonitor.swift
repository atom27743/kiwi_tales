import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionDescription = ""
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionDescription = self?.getConnectionDescription(path) ?? ""
            }
        }
        monitor.start(queue: queue)
    }
    
    private func getConnectionDescription(_ path: NWPath) -> String {
        if path.status == .satisfied {
            if path.usesInterfaceType(.wifi) {
                return "WiFi"
            } else if path.usesInterfaceType(.cellular) {
                return "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                return "Ethernet"
            } else {
                return "Unknown"
            }
        } else {
            return "No Connection"
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
