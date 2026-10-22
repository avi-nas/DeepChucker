import Foundation

@MainActor
internal class Storage: NSObject, ObservableObject {
    internal static let shared: Storage = Storage()
    internal static var limit: NSNumber? = nil
    internal static var defaultFilter: String? = nil
    
    @Published internal private(set) var requests: [RequestModel] = []
    
    internal func saveRequest(_ request: RequestModel?) {
        guard let request = request else { return }
        
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index] = request
        } else {
            requests.insert(request, at: 0)
            
            if let limit = Storage.limit?.intValue, requests.count > limit {
                requests.removeLast()
            }
        }
    }
    
    internal func clearRequests() {
        requests.removeAll()
    }
}
