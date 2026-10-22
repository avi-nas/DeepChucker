# DeepChucker 🚀
### The In-App HTTP & GraphQL Network Inspector for iOS (Chucker for iOS)

[![Swift](https://img.shields.io/badge/Swift-5.9%2B%20%7C%206.0-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%2016.0%2B-blue.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager/)
[![Architecture](https://img.shields.io/badge/Pure_Swift-100%25-green.svg?style=flat-square)](#)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square)](#)

> **Looking for the iOS equivalent of Android's [Chucker](https://github.com/ChuckerTeam/chucker)?**  
> **DeepChucker** brings that exact seamless in-app HTTP inspection experience to iOS—built from the ground up in **100% pure Swift**, with **first-class GraphQL support**, and zero proxy/certificate configuration.

---

## 🌟 Why DeepChucker?

Debugging network traffic on iOS usually means setting up desktop proxies (like Charles or Proxyman), installing custom SSL certificates, and wrestling with certificate pinning or VPN configurations.

**DeepChucker inspects traffic directly inside your app on physical devices and simulators.**

```
┌────────────────────────────────────────────────────────┐
│  REST API   ──► [ GET /api/v1/users ]      Status: 200 │
│  GraphQL    ──► [ GQL ] GetUserProfile     Status: 200 │  ◄── DeepChucker inspects both
│  GraphQL    ──► [ GQL ] UpdateCheckoutCart Status: 400 │      with unified search!
└────────────────────────────────────────────────────────┘
```

### ⚡ Feature Comparison

| Feature | Android Chucker | Desktop Proxies (Charles/Proxyman) | **DeepChucker (iOS)** |
|:---|:---:|:---:|:---:|
| **Platform** | Android | Mac / Windows | **iOS 16+** |
| **In-App Inspection UI** | ✅ Yes | ❌ External desktop only | ✅ **Native SwiftUI UI** |
| **SSL / Certificate Setup** | None needed | Requires trusted root CA | **None needed** |
| **GraphQL Operation Recognition** | ⚠️ Generic POST only | ⚠️ Generic POST only | ✅ **Dedicated GQL Inspector** |
| **GraphQL Search by Operation** | ❌ No | ⚠️ Query body search | ✅ **Instant Query Name Search** |
| **cURL & Postman v2.1 Export** | ✅ Yes | Partial | ✅ **1-Click Share Sheet** |
| **Works on Real Devices in Field** | ✅ Yes | ❌ Requires same Wi-Fi / VPN | ✅ **Anywhere (QA, Beta, Field)** |
| **Pure Swift (No Obj-C)** | N/A | N/A | ✅ **100% Swift** |

---

## 🎯 Key Capabilities

- 🔮 **First-Class GraphQL Inspector & Search**:
  - Automatically extracts `operationName` from `POST` JSON payloads, `GET` query parameters, and batch GraphQL requests.
  - Falls back to query syntax parsing (`query <Name>`, `mutation <Name>`) if `operationName` is omitted.
  - Dedicated **GraphQL tab**: view pretty-printed queries, JSON variables, and operation names with one-tap copy.
- 🔎 **Unified Instant Search**:
  - Search both REST API endpoints and GraphQL operation names in one unified search bar.
- 🚀 **1-Line Startup**:
  - Call `DeepChucker.start()` in your app launch—no complex configuration or boilerplate.
- 🔄 **Automatic Interception**:
  - Intercepts standard `URLSession`, **Alamofire**, **Apollo iOS GraphQL**, and other third-party HTTP clients.
- 📱 **Native SwiftUI Design**:
  - Fluid, responsive interface supporting both Light and Dark mode, status code pills (2xx, 3xx, 4xx, 5xx), and duration metrics.
- 📤 **Instant Export & Sharing**:
  - Share individual calls or filtered lists as **cURL commands**, **Postman Collections (v2.1)**, or formatted text.
- 🛡️ **Privacy & Whitelisting**:
  - Exclude high-frequency telemetry/analytics domains using `DeepChucker.ignoredHosts`.

---

## 📦 Requirements

- **iOS 16.0+**
- **Swift 5.9+ / Swift 6**
- **Xcode 15+**

---

## 🛠️ Installation

### Swift Package Manager (SPM)

Add DeepChucker directly in Xcode via **File > Add Package Dependencies...**:

```text
https://github.com/avi-nas/DeepChucker
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/avi-nas/DeepChucker", from: "1.0.0")
]
```

Add `DeepChucker` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "DeepChucker", package: "DeepChucker")
    ]
)
```

---

## 🚀 Quick Start

### 1. Initialize on App Launch

#### UIKit (`AppDelegate.swift`)
```swift
import UIKit
import DeepChucker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        DeepChucker.start()
        #endif
        return true
    }
}
```

#### SwiftUI (`App.swift`)
```swift
import SwiftUI
import DeepChucker

@main
struct MyApp: App {
    init() {
        #if DEBUG
        DeepChucker.start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## 📱 How to Open DeepChucker

### 1. Shake Your Device
Simply shake your physical device or press `Ctrl + Cmd + Z` in the iOS Simulator.

### 2. Programmatic Presentation (Custom Debug Button / Menu)
```swift
// Present DeepChucker UI
DeepChucker.show()

// Dismiss DeepChucker UI
DeepChucker.dismiss()
```

---

## 🔮 GraphQL Inspection & Search in Action

### Automatic Operation Detection
Standard iOS network tools treat all GraphQL requests as identical `POST /graphql` calls. DeepChucker parses the payload and surfaces the operation name prominently:

```json
{
  "operationName": "FetchUserProfile",
  "query": "query FetchUserProfile($id: ID!) { user(id: $id) { name email avatar } }",
  "variables": { "id": "42" }
}
```

- **In the List View**: Appears as `[GQL] FetchUserProfile` with a distinctive badge.
- **In the Search Bar**: Typing `FetchUserProfile` immediately isolates this call from thousands of REST requests.
- **In the Detail View**: Displays a dedicated **GraphQL section** showing:
  - **Operation Name** (Tap to copy)
  - **Monospace Query** (Formatted and easy to read)
  - **JSON Variables** (Pretty-printed)

---

## ⚙️ Configuration & Customization

```swift
#if DEBUG
// 1. Start interception
DeepChucker.start()

// 2. Ignore analytics or noise domains (supports suffix matching)
DeepChucker.ignoredHosts = [
    "google-analytics.com",
    "telemetry.internal.company.com",
    "crashlytics.com"
]

// 3. Limit stored calls in memory (default is unlimited)
DeepChucker.limit = 250

// 4. Pre-fill default search filter
DeepChucker.defaultFilter = "api/v2"

// 5. Disable shake gesture if you prefer only button triggers
DeepChucker.shakeEnabled = false

// 6. Clear captured requests programmatically
DeepChucker.clearRequests {
    print("All requests flushed from memory")
}
#endif
```

### Environment Variable Override
You can disable shake detection across test schemes by adding the environment variable:
```text
DEEPCHUCKER_SHAKE_ENABLED = NO
```

---

## 🤝 Works Seamlessly With

- **Standard `URLSession`** (`URLSession.shared` & custom sessions)
- **Alamofire**
- **Apollo iOS GraphQL**
- **Moya**
- **Swift OpenAPI Generator**

---

## 📄 License

DeepChucker is open-source software available under the [MIT License](LICENSE).
