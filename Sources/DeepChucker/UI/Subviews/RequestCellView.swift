import SwiftUI

internal struct RequestCellView: View {
    @ObservedObject var request: RequestModel

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(request.method.uppercased())
                    .font(.subheadline)
                    .bold()
                
                if request.code != 0 {
                    Text("\(request.code)")
                        .font(.caption)
                        .bold()
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 6)
                                        .stroke(Colors.HTTPCode.getHTTPCodeColor(code: request.code), lineWidth: 0.5))
                        .foregroundColor(Colors.HTTPCode.getHTTPCodeColor(code: request.code))
                }
                
                if let duration = request.duration {
                    Text(duration.formattedMilliseconds())
                        .font(.footnote)
                }
            }
            .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                if let opName = request.graphQLOperationName, !opName.isEmpty {
                    HStack(spacing: 6) {
                        Text("GQL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.pink)
                            .cornerRadius(4)
                        
                        Text(opName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                } else if request.isGraphQL {
                    Text("GQL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.pink)
                        .cornerRadius(4)
                }
                
                Text(request.url)
                    .font(.subheadline)
                    .foregroundColor(request.isGraphQL ? .secondary : .primary)
                    .lineLimit(request.isGraphQL ? 2 : 5)
                    .multilineTextAlignment(.leading)
            }
            .padding([.leading, .trailing], 8)
            
            Spacer()
        }
    }
}

struct RequestCellView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeGQLRequest = RequestModel(
            id: UUID().uuidString,
            url: "https://example.com/graphql",
            host: "example.com",
            port: 443,
            scheme: "https",
            startDate: Date(),
            method: "POST",
            headers: ["Content-Type": "application/json"],
            credentials: [:],
            cookies: nil,
            httpBody: nil,
            code: 200,
            responseHeaders: ["Content-Type": "application/json"],
            dataResponse: nil,
            errorClientDescription: nil,
            duration: 0.35,
            isGraphQL: true,
            graphQLOperationName: "GetUserProfile",
            graphQLQuery: "query GetUserProfile { user { id name } }",
            graphQLVariables: "{}"
        )
        
        RequestCellView(request: fakeGQLRequest)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
