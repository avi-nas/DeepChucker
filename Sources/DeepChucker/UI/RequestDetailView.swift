import SwiftUI

internal struct RequestDetailView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var request: RequestModel
    @State private var shareSheetPayload: ShareSheetPayload?

    var body: some View {
        List {
            if request.isGraphQL {
                Section("GraphQL") {
                    if let opName = request.graphQLOperationName {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Operation Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(opName)
                                .font(.body)
                                .bold()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            copyToClipboard(text: opName)
                        }
                    }

                    if let query = request.graphQLQuery {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Query")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(query)
                                .font(.system(.footnote, design: .monospaced))
                                .lineLimit(12)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            copyToClipboard(text: query)
                        }
                    }

                    if let variables = request.graphQLVariables {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Variables")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(variables)
                                .font(.system(.footnote, design: .monospaced))
                                .lineLimit(8)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            copyToClipboard(text: variables)
                        }
                    }
                }
            }

            Section("Overview") {
                Text(RequestModelBeautifier.overview(request: request).0)
                    .onTapGesture {
                        copyToClipboard(text: RequestModelBeautifier.overview(request: request).1)
                    }
            }

            Section("Request Header") {
                Text(RequestModelBeautifier.header(request.headers).0)
                    .onTapGesture {
                        copyToClipboard(text: RequestModelBeautifier.header(request.headers).1)
                    }
            }

            Section("Request Body") {
                if let httpBody = request.httpBody {
                    NavigationLink("View body") {
                        BodyDetailView(dataBody: httpBody, kind: .request)
                    }
                } else {
                    Text("No body available")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Response Header") {
                Text(RequestModelBeautifier.header(request.responseHeaders).0)
                    .onTapGesture {
                        copyToClipboard(text: RequestModelBeautifier.header(request.responseHeaders).1)
                    }
            }

            Section("Response Body") {
                if let dataResponse = request.dataResponse {
                    NavigationLink("View body") {
                        BodyDetailView(dataBody: dataResponse, kind: .response)
                    }
                } else {
                    Text("No body available")
                        .foregroundStyle(.secondary)
                }
            }

            if let errorDescription = request.errorClientDescription {
                Section("Error") {
                    Text("**Error**: \(errorDescription)")
                        .foregroundColor(.red)
                        .onTapGesture {
                            copyToClipboard(text: errorDescription)
                        }
                }
            }
        }
        .textSelection(.enabled)
        .listStyle(.insetGrouped)
        .navigationTitle(navigationTitleText)
        .inlineToolbarTitle()
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Share", systemImage: "square.and.arrow.up") {
                        presentShareSheet(with: .flat)
                    }
                    Button("Share as cURL", systemImage: "terminal") {
                        presentShareSheet(with: .curl)
                    }
                    Button("Share as Postman", systemImage: "shippingbox") {
                        presentShareSheet(with: .postman)
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $shareSheetPayload) { payload in
            ShareUtils.shareRequests(requests: payload.requests, requestExportOption: payload.exportOption)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private var navigationTitleText: String {
        if let opName = request.graphQLOperationName, !opName.isEmpty {
            return opName
        }
        return URL(string: request.url)?.path ?? "Request Detail"
    }

    private func presentShareSheet(with option: RequestResponseExportOption) {
        shareSheetPayload = ShareSheetPayload(requests: [request], exportOption: option)
    }
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        alertMessage = "Copied to clipboard"
        showAlert = true
    }
}

private struct ShareSheetPayload: Identifiable {
    let id = UUID()
    let requests: [RequestModel]
    let exportOption: RequestResponseExportOption
}

private struct InlineToolbarTitle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.toolbarTitleDisplayMode(.inline)
        } else {
            content
        }
    }
}

private extension View {
    func inlineToolbarTitle() -> some View {
        modifier(InlineToolbarTitle())
    }
}

struct RequestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeGQLRequest = RequestModel(
            id: UUID().uuidString,
            url: "https://example.com/graphql",
            host: "example.com",
            port: 443,
            scheme: "https",
            startDate: Date(),
            method: "POST",
            headers: [
                "Content-Type": "application/json",
                "User-Agent": "DeepChucker/1.0"
            ],
            credentials: [:],
            cookies: nil,
            httpBody: nil,
            code: 200,
            responseHeaders: [
                "Content-Type": "application/json"
            ],
            dataResponse: nil,
            errorClientDescription: nil,
            duration: 0.25,
            isGraphQL: true,
            graphQLOperationName: "GetUserProfile",
            graphQLQuery: "query GetUserProfile { user { id name email } }",
            graphQLVariables: "{\n  \"userId\": \"123\"\n}"
        )

        return RequestDetailView(request: fakeGQLRequest)
    }
}
