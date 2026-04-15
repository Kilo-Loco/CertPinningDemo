import Foundation
import CryptoKit

class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    let pinnedKeyHash: String

    init(pinnedKeyHash: String) {
        self.pinnedKeyHash = pinnedKeyHash
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {

        guard challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Standard TLS evaluation
        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Extract the leaf certificate's public key and hash it
        guard let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let cert = chain.first,
              let publicKey = SecCertificateCopyKey(cert),
              let keyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let hash = SHA256.hash(data: keyData)
        let hashBase64 = Data(hash).base64EncodedString()

        if hashBase64 == pinnedKeyHash {
            return (.useCredential, URLCredential(trust: serverTrust))
        } else {
            // Hash mismatch. Possible man-in-the-middle.
            return (.cancelAuthenticationChallenge, nil)
        }
    }
}
