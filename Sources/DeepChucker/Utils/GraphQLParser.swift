import Foundation

internal struct GraphQLDetails: Equatable {
    let isGraphQL: Bool
    let operationName: String?
    let query: String?
    let variables: String?
}

internal class GraphQLParser {
    
    private static let operationRegex: NSRegularExpression? = {
        let pattern = #"(?i)(?:query|mutation|subscription)\s+([A-Za-z0-9_]+)"#
        return try? NSRegularExpression(pattern: pattern, options: [])
    }()

    static func parse(url: String, httpBody: Data?) -> GraphQLDetails {
        // 1. Try to parse from HTTP Body (POST requests)
        if let bodyData = httpBody,
           let json = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
            
            // Single operation dictionary
            if let dict = json as? [String: Any] {
                if let details = parse(dictionary: dict) {
                    return details
                }
            }
            
            // Batch operations array
            if let array = json as? [[String: Any]], !array.isEmpty {
                var operationNames: [String] = []
                var queries: [String] = []
                
                for dict in array {
                    if let details = parse(dictionary: dict) {
                        if let name = details.operationName, !name.isEmpty {
                            operationNames.append(name)
                        }
                        if let q = details.query, !q.isEmpty {
                            queries.append(q)
                        }
                    }
                }
                
                if !operationNames.isEmpty || !queries.isEmpty {
                    let combinedName = operationNames.isEmpty ? nil : operationNames.joined(separator: ", ")
                    let combinedQuery = queries.isEmpty ? nil : queries.joined(separator: "\n---\n")
                    return GraphQLDetails(
                        isGraphQL: true,
                        operationName: combinedName,
                        query: combinedQuery,
                        variables: nil
                    )
                }
            }
        }
        
        // 2. Try to parse from URL query parameters (GET requests)
        if let components = URLComponents(string: url), let queryItems = components.queryItems {
            var operationName: String?
            var queryString: String?
            var variablesString: String?
            
            for item in queryItems {
                if item.name.caseInsensitiveCompare("operationName") == .orderedSame {
                    operationName = item.value
                } else if item.name.caseInsensitiveCompare("query") == .orderedSame {
                    queryString = item.value
                } else if item.name.caseInsensitiveCompare("variables") == .orderedSame {
                    variablesString = item.value
                }
            }
            
            if operationName != nil || queryString != nil {
                if (operationName == nil || operationName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true),
                   let q = queryString {
                    operationName = extractOperationName(fromQuery: q)
                }
                
                return GraphQLDetails(
                    isGraphQL: true,
                    operationName: operationName,
                    query: queryString,
                    variables: variablesString
                )
            }
        }
        
        return GraphQLDetails(isGraphQL: false, operationName: nil, query: nil, variables: nil)
    }
    
    private static func parse(dictionary: [String: Any]) -> GraphQLDetails? {
        let hasQuery = dictionary["query"] != nil
        let hasOpName = dictionary["operationName"] != nil
        
        guard hasQuery || hasOpName else { return nil }
        
        var operationName: String? = nil
        if let rawOpName = dictionary["operationName"] as? String, !rawOpName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            operationName = rawOpName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let query = dictionary["query"] as? String
        
        // If operationName is not set in dictionary, extract from query string if available
        if operationName == nil, let queryText = query {
            operationName = extractOperationName(fromQuery: queryText)
        }
        
        var variablesString: String? = nil
        if let variables = dictionary["variables"] {
            if let varDict = variables as? [String: Any] {
                if let jsonData = try? JSONSerialization.data(withJSONObject: varDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: jsonData, encoding: .utf8) {
                    variablesString = str
                }
            } else if let varStr = variables as? String {
                variablesString = varStr
            }
        }
        
        return GraphQLDetails(
            isGraphQL: true,
            operationName: operationName,
            query: query,
            variables: variablesString
        )
    }
    
    private static func extractOperationName(fromQuery query: String) -> String? {
        guard let regex = operationRegex else { return nil }
        let range = NSRange(query.startIndex..<query.endIndex, in: query)
        if let match = regex.firstMatch(in: query, options: [], range: range),
           match.numberOfRanges > 1,
           let nameRange = Range(match.range(at: 1), in: query) {
            return String(query[nameRange])
        }
        return nil
    }
}
