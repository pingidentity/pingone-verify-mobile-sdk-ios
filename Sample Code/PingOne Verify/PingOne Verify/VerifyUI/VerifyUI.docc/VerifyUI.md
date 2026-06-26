# ``VerifyUI``

Open-source built-in-UI source for PingOne Verify iOS — copy this folder into your app target when you want the SDK's ready-made screens.

## Overview

`VerifyUI` is open-source and ships as compilable Swift source inside `PingOneVerifySample/VerifyUI/`.
It provides ``PingOneVerifyHelper`` plus the supporting screens — document capture, OTP input,
retry dialogs, geolocation retry, and a themed navigation stack — that drive the built-in verification UI.

Because it ships as source (not a prebuilt framework), you can freely customise any screen, string,
or layout. Copy the `VerifyUI/` folder into your own app target and compile it directly — no separate
framework import is needed.

If you only need a fully custom UI, use ``PingOneVerifyClient/Builder`` from `PingOneVerify` directly —
you do not need to include `VerifyUI` at all in that case.

### Built-in UI quick start

The SDK no longer ships its own QR scanner; supply the verification URL up front (scan it yourself,
or read it from your backend). Construct a ``PingOneVerifyHelper``, wire it as the coordinator
delegate, and call ``PingOneVerifyHelper/start()``. `Builder.build()` returns the client
immediately — `start()` then concurrently fetches the app theme and language pack, firing
`coordinator(_:didReceiveAppTheme:error:)` and `coordinator(_:didReceiveLanguagePack:error:)`,
and starts the verification flow only after both fetches complete.

```swift
// VerifyUI source is compiled into your target — no `import VerifyUI`.
import PingOneVerify
import NeoInterfaces   // for DocumentClass, DocumentCaptureSettings, etc.

PingOneVerifyHelper.initialize(with: scannedQr, rootViewController: self) { helper, error in
    helper?.start()                 // present nav, fetch theme+language pack, start session
}
```

## Topics

### Built-in UI driver

- ``PingOneVerifyHelper``

### Capture presenter protocols

- ``DocumentCaptureContract``

### Localisation

- ``VerifyLanguagePackProvider``
