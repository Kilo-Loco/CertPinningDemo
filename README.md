# CertPinningDemo

Minimal iOS project demonstrating certificate pinning with `URLSessionDelegate` and CryptoKit.

Two buttons: one makes a standard request, the other makes a pinned request. Run [mitmproxy](https://mitmproxy.org/) and the pinned request fails while the unpinned one goes through.

## Article

[I Used mitmproxy to Read My App's AI System Prompt. Then I Built the Defense.](https://www.kiloloco.com/articles/mitmproxy-certificate-pinning-ios)
