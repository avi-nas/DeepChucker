import Foundation
import XCTest
@testable import DeepChucker

class DeepChuckerTests: XCTestCase {
    
    func testGraphQLPostWithExplicitOperationName() {
        let json = """
        {
            "operationName": "GetUserProfile",
            "query": "query GetUserProfile { user { id name } }",
            "variables": { "userId": "123" }
        }
        """.data(using: .utf8)
        
        let request = RequestModel(
            url: "https://api.example.com/graphql",
            method: "POST",
            httpBody: json
        )
        
        XCTAssertTrue(request.isGraphQL)
        XCTAssertEqual(request.graphQLOperationName, "GetUserProfile")
        XCTAssertEqual(request.graphQLQuery, "query GetUserProfile { user { id name } }")
        XCTAssertNotNil(request.graphQLVariables)
    }
    
    func testGraphQLPostWithoutOperationNameFallbackToQuery() {
        let json = """
        {
            "query": "query FetchDashboardMetrics { metrics { cpu memory } }"
        }
        """.data(using: .utf8)
        
        let request = RequestModel(
            url: "https://api.example.com/graphql",
            method: "POST",
            httpBody: json
        )
        
        XCTAssertTrue(request.isGraphQL)
        XCTAssertEqual(request.graphQLOperationName, "FetchDashboardMetrics")
    }
    
    func testGraphQLMutationOperationName() {
        let json = """
        {
            "query": "mutation UpdateUserStatus($status: String!) { updateStatus(status: $status) { success } }"
        }
        """.data(using: .utf8)
        
        let request = RequestModel(
            url: "https://api.example.com/graphql",
            method: "POST",
            httpBody: json
        )
        
        XCTAssertTrue(request.isGraphQL)
        XCTAssertEqual(request.graphQLOperationName, "UpdateUserStatus")
    }
    
    func testGraphQLGetRequestWithQueryParameters() {
        let url = "https://api.example.com/graphql?operationName=GetFeed&query=query%20GetFeed%20%7B%20feed%20%7D"
        
        let request = RequestModel(
            url: url,
            method: "GET",
            httpBody: nil
        )
        
        XCTAssertTrue(request.isGraphQL)
        XCTAssertEqual(request.graphQLOperationName, "GetFeed")
    }
    
    func testGraphQLBatchRequests() {
        let json = """
        [
            { "operationName": "GetFeed", "query": "query GetFeed { feed }" },
            { "operationName": "GetNotifications", "query": "query GetNotifications { notifications }" }
        ]
        """.data(using: .utf8)
        
        let request = RequestModel(
            url: "https://api.example.com/graphql",
            method: "POST",
            httpBody: json
        )
        
        XCTAssertTrue(request.isGraphQL)
        XCTAssertEqual(request.graphQLOperationName, "GetFeed, GetNotifications")
    }
    
    func testNonGraphQLRestRequest() {
        let json = """
        {
            "username": "johndoe",
            "email": "john@example.com"
        }
        """.data(using: .utf8)
        
        let request = RequestModel(
            url: "https://api.example.com/v1/users",
            method: "POST",
            httpBody: json
        )
        
        XCTAssertFalse(request.isGraphQL)
        XCTAssertNil(request.graphQLOperationName)
        XCTAssertNil(request.graphQLQuery)
    }
    
    func testRequestModelCopyUpdatesGraphQL() {
        let initialRequest = RequestModel(
            url: "https://api.example.com/graphql",
            method: "POST",
            httpBody: nil
        )
        
        XCTAssertFalse(initialRequest.isGraphQL)
        
        let expectation = expectation(description: "GraphQL details updated asynchronously on main queue")
        
        let newBody = """
        {
            "operationName": "LogoutUser",
            "query": "mutation LogoutUser { logout }"
        }
        """.data(using: .utf8)
        
        initialRequest.copy(httpBody: newBody)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(initialRequest.isGraphQL)
            XCTAssertEqual(initialRequest.graphQLOperationName, "LogoutUser")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testDeepChuckerConfiguration() {
        DeepChucker.ignoredHosts = ["analytics.google.com"]
        XCTAssertEqual(DeepChucker.ignoredHosts, ["analytics.google.com"])
        
        DeepChucker.setEnabled(false)
        XCTAssertFalse(DeepChucker.isEnabled)
        
        DeepChucker.setEnabled(true)
        XCTAssertTrue(DeepChucker.isEnabled)
    }
}
