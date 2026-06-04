import SwiftUI
import SharedCore
import AVFoundation

/// Camera challenge screen. Mirrors Android's CameraChallengeScreen.kt.
/// Uses AVFoundation camera + ML Kit OCR to find kanji in the real world.
struct CameraChallengeView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = CameraChallengeViewModel()
    var targetKanjiId: Int32? = nil
    var onBack: () -> Void = {}
    var onJournal: (() -> Void)? = nil

    @State private var cameraPermissionGranted = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !cameraPermissionGranted {
                permissionDenied
            } else {
                switch viewModel.state {
                case .loading:
                    loadingContent
                case .showTarget(let targetKanji, let challengeNumber, let totalChallenges, _, let sessionXp):
                    cameraWithTarget(targetKanji, challenge: challengeNumber, total: totalChallenges, xp: sessionXp)
                case .success(let targetKanji, let challengeNumber, let totalChallenges, _, _, let xpGained):
                    successOverlay(targetKanji, challenge: challengeNumber, total: totalChallenges, xpGained: xpGained)
                case .sessionComplete(let totalChallenges, let successCount, let accuracy, let totalXp):
                    sessionComplete(total: totalChallenges, success: successCount, accuracy: accuracy, xp: totalXp)
                case .error(let message):
                    errorContent(message)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left"); Text("Back")
                }.foregroundColor(.white)
            }
            ToolbarItem(placement: .principal) {
                Text("Camera Challenge").font(.headline).foregroundColor(.white)
            }
            if let onJournal = onJournal {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onJournal) {
                        Text("\u{1F4D3}").font(.system(size: 20))
                    }.foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            viewModel.load(container: container)
            await checkCameraPermission()
        }
    }

    // MARK: - Camera Permission

    private func checkCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            viewModel.startSession(targetKanjiId: targetKanjiId)
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraPermissionGranted = granted
            if granted { viewModel.startSession(targetKanjiId: targetKanjiId) }
        default:
            cameraPermissionGranted = false
        }
    }

    private var permissionDenied: some View {
        VStack(spacing: 16) {
            Text("Camera permission is required for this mode")
                .font(KanjiJourneyTheme.bodyLarge)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .fontWeight(.bold).foregroundColor(.white)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(KanjiJourneyTheme.primary).cornerRadius(8)
        }
        .padding(24)
    }

    // MARK: - Loading

    private var loadingContent: some View {
        VStack(spacing: 16) {
            ProgressView().tint(.white)
            Text("Preparing camera challenges...")
                .font(KanjiJourneyTheme.titleMedium)
                .foregroundColor(.white)
        }
    }

    // MARK: - Camera with Target Overlay

    private func cameraWithTarget(_ kanji: Kanji, challenge: Int, total: Int, xp: Int) -> some View {
        ZStack {
            // Camera preview placeholder
            // TODO: Replace with actual AVCaptureSession + Vision OCR
            CameraPreviewPlaceholder(onTextRecognized: { text in
                viewModel.onTextRecognized(text)
            })

            // Target overlay
            VStack {
                // Progress bar
                HStack {
                    Text("\(challenge) / \(total)")
                        .font(KanjiJourneyTheme.titleMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)

                    Spacer()

                    Text("\(xp) XP")
                        .font(KanjiJourneyTheme.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(KanjiJourneyTheme.xpGold)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                }

                Spacer().frame(height: 24)

                // Target kanji card
                VStack(spacing: 16) {
                    Text("Find and scan this kanji:")
                        .font(KanjiJourneyTheme.titleMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurface)

                    KanjiText(text: kanji.literal)
                        .font(.system(size: 96, weight: .bold))
                        .foregroundColor(KanjiJourneyTheme.primary)

                    Text(kanji.primaryMeaning)
                        .font(KanjiJourneyTheme.bodyLarge)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }
                .padding(24)
                .background(KanjiJourneyTheme.surface)
                .cornerRadius(16)
                .shadow(radius: 8)

                Spacer()

                // Scanning indicator
                if viewModel.isScanning {
                    Text("Scanning...")
                        .font(KanjiJourneyTheme.titleMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding(.bottom, 32)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Success Overlay

    private func successOverlay(_ kanji: Kanji, challenge: Int, total: Int, xpGained: Int) -> some View {
        ZStack {
            Color(hex: 0x4CAF50).opacity(0.92).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("\u{2713}")
                    .font(.system(size: 120))
                    .foregroundColor(.white)

                Text("Success!")
                    .font(KanjiJourneyTheme.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("+\(xpGained) XP")
                    .font(KanjiJourneyTheme.titleLarge)
                    .fontWeight(.bold)
                    .foregroundColor(KanjiJourneyTheme.xpGold)

                Spacer().frame(height: 16)

                KanjiText(text: kanji.literal)
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text(kanji.primaryMeaning)
                    .font(KanjiJourneyTheme.titleMedium)
                    .foregroundColor(.white.opacity(0.9))

                Spacer().frame(height: 32)

                Button {
                    viewModel.nextChallenge()
                } label: {
                    Text(challenge < total ? "Next Challenge" : "Finish")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x4CAF50))
                        .frame(width: 220, height: 56)
                        .background(.white)
                        .cornerRadius(12)
                }
            }
            .padding(24)
        }
    }

    // MARK: - Session Complete

    private func sessionComplete(total: Int, success: Int, accuracy: Int, xp: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Challenge Complete!")
                .font(KanjiJourneyTheme.headlineMedium)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                statRow("Total Challenges", "\(total)")
                statRow("Successfully Scanned", "\(success)")
                statRow("Accuracy", "\(accuracy)%")
                statRow("XP Earned", "+\(xp)")
            }
            .padding(20)
            .background(KanjiJourneyTheme.surface)
            .cornerRadius(KanjiJourneyTheme.radiusM)

            Spacer()

            Button {
                viewModel.reset()
                onBack()
            } label: {
                Text("Done")
                    .font(.system(size: 18)).fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(KanjiJourneyTheme.primary).cornerRadius(12)
            }

            if let onJournal = onJournal {
                Button(action: onJournal) {
                    Text("View Field Journal")
                        .font(.system(size: 18))
                        .foregroundColor(KanjiJourneyTheme.primary)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(KanjiJourneyTheme.primary, lineWidth: 1))
                }
            }
        }
        .padding(24)
    }

    // MARK: - Error

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(KanjiJourneyTheme.bodyLarge)
                .multilineTextAlignment(.center)
            Button("Go Back", action: onBack)
                .foregroundColor(KanjiJourneyTheme.primary)
        }
        .padding(24)
    }

    // MARK: - Helpers

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(KanjiJourneyTheme.bodyLarge)
                .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            Spacer()
            Text(value)
                .font(KanjiJourneyTheme.bodyLarge)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Live Camera Preview with Vision OCR

struct CameraPreviewPlaceholder: UIViewRepresentable {
    var onTextRecognized: (String) -> Void

    func makeCoordinator() -> CameraCoordinator {
        CameraCoordinator(onTextRecognized: onTextRecognized)
    }

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.coordinator = context.coordinator
        view.startSession()
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}

    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: CameraCoordinator) {
        uiView.stopSession()
    }
}

final class CameraPreviewUIView: UIView {
    var coordinator: CameraCoordinator?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    func startSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            showFallbackLabel("Camera unavailable")
            return
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(coordinator, queue: DispatchQueue(label: "com.jworks.kanjijourney.camera"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        layer.insertSublayer(preview, at: 0)
        previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    private func showFallbackLabel(_ text: String) {
        backgroundColor = .black
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

import Vision

final class CameraCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let onTextRecognized: (String) -> Void
    private var lastProcessTime: TimeInterval = 0

    init(onTextRecognized: @escaping (String) -> Void) {
        self.onTextRecognized = onTextRecognized
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let now = CACurrentMediaTime()
        guard now - lastProcessTime > 0.5 else { return }
        lastProcessTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognized = observations.compactMap { $0.topCandidates(1).first?.string }.joined()
            if !recognized.isEmpty {
                DispatchQueue.main.async {
                    self?.onTextRecognized(recognized)
                }
            }
        }
        request.recognitionLanguages = ["ja", "en"]
        request.recognitionLevel = .accurate

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
