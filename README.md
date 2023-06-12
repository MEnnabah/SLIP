# SLIP

SLIP is a lightweight package for the SLIP packets, as documented in [RFC 1055](https://datatracker.ietf.org/doc/html/rfc1055.html). It defines encoding and decoding and handles double-ended SLIP encoded packets.

## Installation
SLIP is available as a Swift Package Manager package. You can add it to your project from Xcode's "Swift Packages" option in the File menu.

```
.package(url: "https://github.com/mennabah/SLIP.git", from: "1.0.0")
```

## Usage
SLIP defines a global, single struct access for the functionality of the package. Start by creating an instance:
```swift
let packet = SLIP.Packet(<#T##YourData#>)
``` 

Then use that instance to encode the packet.

```swift
let encoded = packet.encoded
```

Or decode it
```swift
let decoded = try? packet.decoded
```

## Error Hanlding

Contrary to the reference implementation described in RFC 1055, which chooses to essentially ignore protocol errors, the `decoded` method in the SLIP package use a `SLIPError.protocolError` error to indicate protocol errors, i.e. SLIP packets with invalid byte sequences.

You can optionally opt-in to ignore decoding errors by specifying `ignoresError` in the `Packet(_:ignoresProtocolError:)` initializer.
