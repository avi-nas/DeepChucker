# DeepChucker 🚀

[![Swift](https://img.shields.io/badge/Swift-5.9%2B%20%7C%206.0-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%2016.0%2B-blue.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager/)
[![Architecture](https://img.shields.io/badge/Pure_Swift-100%25-green.svg?style=flat-square)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-orange.svg?style=flat-square)](http://makeapullrequest.com)

_The In-App HTTP & GraphQL Network Inspector for iOS_

- [DeepChucker 🚀](#deepchucker-)
  - [Getting Started 👣](#getting-started-)
    - [Installation 🛠️](#installation-️)
    - [Initialize on App Launch 🚀](#initialize-on-app-launch-)
  - [Features 🧰](#features-)
    - [GraphQL Inspection & Search 🔮](#graphql-inspection--search-)
    - [How to Open DeepChucker 📱](#how-to-open-deepchucker-)
  - [Configure 🎨](#configure-)
    - [Ignore Noise & Telemetry 🛡️](#ignore-noise--telemetry-️)
    - [Environment Variable Override ⚙️](#environment-variable-override-️)
  - [Compatibility 🤝](#compatibility-)
  - [FAQ ❓](#faq-)
  - [Contributing 🤝](#contributing-)
  - [Acknowledgments 🌸](#acknowledgments-)

**DeepChucker** simplifies the inspection of **HTTP(S) and GraphQL requests/responses** fired by your iOS app. Built from the ground up in **100% pure Swift**, DeepChucker automatically intercepts network traffic inside your application and provides a native SwiftUI interface for inspecting, searching, and sharing network calls—with zero desktop proxy or SSL certificate setup.

Apps using DeepChucker can trigger the inspector UI anytime by **shaking the device** or calling `DeepChucker.show()` directly from a custom debug menu.

```text
┌────────────────────────────────────────────────────────┐
│  REST API   ──► [ GET /api/v1/users ]      Status: 200 │
│  GraphQL    ──► [ GQL ] GetUserProfile     Status: 200 │  ◄── DeepChucker inspects both
│  GraphQL    ──► [ GQL ] UpdateCheckoutCart Status: 400 │      with unified search!
└────────────────────────────────────────────────────────┘
```

---

## Getting Started 👣

### Installation 🛠️

DeepChucker is distributed via **Swift Package Manager (SPM)**.

Add DeepChucker directly in Xcode via **File > Add Package Dependencies...**:

```text
https://github.com/avi-nas/DeepChucker
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/avi-nas/DeepChucker", from: "1.0.2")
]
```

Then add `DeepChucker` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "DeepChucker", package: "DeepChucker")
    ]
)
```

### Initialize on App Launch 🚀

To start capturing network traffic, initialize DeepChucker when your app launches. Wrap it in `#if DEBUG` to isolate DeepChucker from production builds:

#### SwiftUI (`App.swift`)

```swift
import SwiftUI
import DeepChucker

@main
struct MyApp: App {
    init() {
        #if DEBUG
        DeepChucker.start()
        DeepChucker.setEnabled(true)
        DeepChucker.shakeEnabled = true
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### UIKit (`AppDelegate.swift`)

```swift
import UIKit
import DeepChucker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        DeepChucker.start()
        DeepChucker.setEnabled(true)
        DeepChucker.shakeEnabled = true
        #endif
        return true
    }
}
```

**That's it!** 🎉 DeepChucker will now automatically record all HTTP and GraphQL interactions made by your app.

---

## Features 🧰

* **iOS 16.0+** & **Swift 5.9+ / 6.0** compatible
* **100% Pure Swift** architecture (zero Objective-C runtime hacks)
* Easy to integrate (quick startup configuration)
* Works **out of the box** with zero proxy or SSL certificate setup
* **First-class GraphQL support** with automatic `operationName` extraction 🔮
* **Unified instant search** across REST endpoints and GraphQL operation names 🔎
* **Native SwiftUI design** with Light & Dark mode, status code pills (2xx, 3xx, 4xx, 5xx), and duration metrics 📱
* **1-Click Export & Sharing** as **cURL commands**, **Postman Collections (v2.1)**, or formatted text 📤
* **Domain Whitelisting / Filtering** to ignore noisy analytics or telemetry hosts 🛡️

### GraphQL Inspection & Search 🔮

Standard network tools list every GraphQL call as an identical `POST /graphql` request. DeepChucker automatically parses `POST` JSON payloads, `GET` query parameters, batch requests, and raw query definitions (`query <Name>`, `mutation <Name>`) to surface the operation name right in the request list:

```json
{
  "operationName": "FetchUserProfile",
  "query": "query FetchUserProfile(\$id: ID!) { user(id: \$id) { name email avatar } }",
  "variables": { "id": "42" }
}
```

* **In the List View**: Appears as `[GQL] FetchUserProfile` with a dedicated badge.
* **In the Search Bar**: Typing `FetchUserProfile` immediately isolates the operation from thousands of REST calls.
* **In the Detail View**: Features a dedicated **GraphQL tab** displaying the **Operation Name** (one-tap copy), **Formatted Query**, and **Pretty-Printed JSON Variables**.

### How to Open DeepChucker 📱

1. **Shake Gesture**: Shake your physical iOS device or press `Ctrl + Cmd + Z` in the iOS Simulator.
2. **Programmatic Presentation**: Present or dismiss the inspector from your own debug menu or floating button:

```swift
// Present DeepChucker UI
DeepChucker.show()

// Dismiss DeepChucker UI
DeepChucker.dismiss()
```

---

## Configure 🎨

You can customize DeepChucker's behavior at startup to fit your workflow:

```swift
#if DEBUG
// 1. Start interception & enable DeepChucker
DeepChucker.start()
DeepChucker.setEnabled(true)

// 2. Enable or disable shake gesture trigger
DeepChucker.shakeEnabled = true

// 3. Ignore analytics or noise domains (supports suffix matching)
DeepChucker.ignoredHosts = [
    "google-analytics.com",
    "telemetry.internal.company.com",
    "crashlytics.com"
]

// 4. Limit stored calls in memory (default is unlimited)
DeepChucker.limit = 250

// 5. Pre-fill default search filter
DeepChucker.defaultFilter = "api/v2"

// 6. Clear captured requests programmatically
DeepChucker.clearRequests {
    print("All requests flushed from memory")
}
#endif
```

### Ignore Noise & Telemetry 🛡️

**Warning**: The data captured by DeepChucker may contain sensitive information such as `Authorization` headers, cookies, and personal data in request/response bodies. It is intended **strictly for development and QA testing**, not production releases.

To prevent high-frequency telemetry or third-party SDK traffic from cluttering your inspector, configure `DeepChucker.ignoredHosts`:

```swift
DeepChucker.ignoredHosts = ["segment.io", "mixpanel.com"]
```

### Environment Variable Override ⚙️

You can disable the shake gesture across specific Xcode schemes or UI test targets without changing code by setting the environment variable in your scheme:

```text
DEEPCHUCKER_SHAKE_ENABLED = NO
```

---

## Compatibility 🤝

DeepChucker intercepts traffic seamlessly across popular iOS networking stacks:

* **Standard `URLSession`** (`URLSession.shared` & custom configurations)
* **Alamofire**
* **Apollo iOS GraphQL**
* **Moya**
* **Swift OpenAPI Generator**

---

## FAQ ❓

* **Why aren't requests from my custom `URLSession` appearing?**
  Make sure `DeepChucker.start()` and `DeepChucker.setEnabled(true)` are called **before** initializing your custom `URLSession` or third-party network client (such as Alamofire or Apollo) so the protocol interceptor is registered in time.

* **Does DeepChucker impact production builds?**
  When wrapped in `#if DEBUG` (or toggled off via `DeepChucker.setEnabled(false)`), DeepChucker is inactive in release builds. For complete isolation, only link or initialize DeepChucker in Debug configurations.

* **How do I export a request to Postman?**
  Open any request (or filter a list of requests), tap the **Share / Export** icon in the top-right corner, and choose **Export as cURL** or **Postman Collection (v2.1)**.

---

## Contributing 🤝

**We're looking for contributors! Don't be shy.** 😁 Feel free to open issues or pull requests to help improve DeepChucker.

* When reporting a new **Issue**, please attach **screenshots, videos, or sample payloads** demonstrating the problem.
* When submitting a **Pull Request**, ensure your code compiles cleanly on **Xcode 15+ (Swift 5.9+ / 6.0)** and all tests pass.

---

## Acknowledgments 🌸

* Big thanks to all contributors who help make iOS network debugging effortless ❤️
