import UIKit
import Foundation
import DeepChucker

class ViewController: UIViewController {

    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard !isRunningTests else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            DataFetcher.sharedInstance.getPost(id: Utils.random(max: 128), completion: {
                print("API: Get random post")
            }) { _ in
                print("ERROR: api Get post")
            }
            
            if let strongSelf = self {
                strongSelf.getPhotosButtonPressed(strongSelf)
            }
        }
        timer.fire()
    }
    
    // MARK: - Actions
    @IBAction func getPostsButtonPressed(_ sender: Any) {
        DataFetcher.sharedInstance.getPost(id: 1, completion: {
            print("API: Get post")
        }) { _ in
            print("ERROR: api Get post")
        }
    }
    
    @IBAction func newRandomPostButtonPressed(_ sender: Any) {
        DataFetcher.sharedInstance.newPost(userId: Utils.random(max: 5000), title: Utils.random(128), body: Utils.random(5000), completion: {
            print("API: New post")
        }) { _ in
            print("ERROR: api New post")
        }
    }
    
    @IBAction func getWrongURLButtonPressed(_ sender: Any) {
        DataFetcher.sharedInstance.getWrongURL(completion: {
            print("API: Wrong URL")
        }) { _ in
            print("ERROR: api Wrong URL")
        }
    }
    
    @IBAction func getPhotosButtonPressed(_ sender: Any) {
        DataFetcher.sharedInstance.getPhotosList(completion: {
            print("API: Get photos")
        }) { _ in
            print("ERROR: api Get photos")
        }
    }
    
    @IBAction func triggerGraphQLSampleButtonPressed(_ sender: Any) {
        guard let url = URL(string: "https://countries.trevorblades.com/graphql") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "operationName": "GetCountryDetails",
            "query": "query GetCountryDetails { country(code: \"US\") { name native emoji currency } }",
            "variables": [:]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            print("API: GraphQL sample executed")
        }.resume()
    }
}
