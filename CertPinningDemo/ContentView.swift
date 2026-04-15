import SwiftUI

struct ContentView: View {
    @State private var result = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(result.isEmpty ? "Tap a button to make an API call." : result)
                    .font(.body.monospaced())
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                if isLoading {
                    ProgressView()
                }

                Button("Fetch Without Pinning") {
                    fetch(pinned: false)
                }
                .buttonStyle(.borderedProminent)

                Button("Fetch With Pinning") {
                    fetch(pinned: true)
                }
                .buttonStyle(.bordered)

                Text("Run mitmproxy on your Mac to see the difference.\nThe pinned request will fail if a proxy is intercepting.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Cert Pinning Demo")
        }
    }

    private func fetch(pinned: Bool) {
        result = ""
        isLoading = true

        Task {
            do {
                let data = try await APIClient.shared.fetch(pinCertificate: pinned)
                let preview = String(data: data, encoding: .utf8) ?? "\(data.count) bytes"
                result = "[\(pinned ? "PINNED" : "UNPINNED")] Success.\n\n\(preview)"
            } catch {
                result = "[\(pinned ? "PINNED" : "UNPINNED")] Failed.\n\n\(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
