import Foundation

class APIClient {
    static let shared = APIClient()

    private let testURL = URL(string: "https://httpbin.org/get")!

    // SHA-256 hash of httpbin.org's TLS public key.
    // Generate with:
    //   echo | openssl s_client -connect httpbin.org:443 \
    //     -servername httpbin.org 2>/dev/null \
    //     | openssl x509 -pubkey -noout \
    //     | openssl pkey -pubin -outform DER \
    //     | openssl dgst -sha256 -binary \
    //     | base64
    private let pinnedKeyHash = "5BWYNtPxvjsl+qhQLxo3jz3ZaK74xyHT/QdOhBB07i0="

    func fetch(pinCertificate: Bool) async throws -> Data {
        let session: URLSession

        if pinCertificate {
            // Pinned: validates the server's public key hash.
            // Rejects connections if a proxy swaps in a fake certificate.
            let delegate = CertificatePinningDelegate(pinnedKeyHash: pinnedKeyHash)
            session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        } else {
            // Unpinned: accepts any certificate from a trusted CA.
            // A proxy like mitmproxy can intercept this.
            session = URLSession.shared
        }

        let (data, _) = try await session.data(from: testURL)
        return data
    }
}
