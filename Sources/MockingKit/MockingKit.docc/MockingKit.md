# ``MockingKit``

MockingKit is a Swift-based mocking library that makes it easy to mock protocols and classes, for instance when unit testing or mocking not yet implemented functionality.


## Overview

![MockingKit logo](Logo.png)

MockingKit lets you `register` function results, `call` functions and `inspect` recorded calls.

MockingKit doesn't put any restrictions on your code or require you to structure it in any way. You don't need any setup or configuration. Just create a mock and you're good to go.



## Installation

MockingKit can be installed with the Swift Package Manager:

```
https://github.com/danielsaidi/MockingKit.git
```

or with CocoaPods:

```
pod MockingKit
```

If you prefer to not have external dependencies, you can also just copy the source code into your app.



## Supported Platforms

MockingKit supports `iOS 13`, `macOS 10.15`, `tvOS 13` and `watchOS 6`.



## About this documentation

The online documentation is currently iOS-specific. To generate documentation for other platforms, open the package in Xcode, select a simulator then run `Product/Build Documentation`.



## License

MockingKit is available under the MIT license.



## Topics

### Articles

- <doc:Getting-Started>

### Foundation

- ``Mock``
- ``Mockable``
- ``MockCall``
- ``MockReference``
- ``AsyncMockReference``

### System Mocks

- ``MockNotificationCenter``
- ``MockPasteboard``
- ``MockTextDocumentProxy``
- ``MockUserDefaults``
