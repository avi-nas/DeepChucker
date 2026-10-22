import Foundation

/// `RequestResponseExportOption` is the type used to handle different export representations of HTTP requests and responses collected by DeepChucker.
internal enum RequestResponseExportOption {
    /// Export a request and its response in a "human" readable mode.
    case flat
    /// Export only the request as a cURL command.
    case curl
    /// Request and response are exported as Postman collection (v.2.1). Response is attached as "example".
    case postman
}
