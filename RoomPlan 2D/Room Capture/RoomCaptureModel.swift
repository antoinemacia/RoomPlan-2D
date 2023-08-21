//
//  RoomCaptureModel.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 24/02/2023.
//

import Foundation
import RoomPlan

class RoomCaptureModel: RoomCaptureSessionDelegate {
    
    // Singleton
    static let shared = RoomCaptureModel()
    
    // The capture view
    let roomCaptureView: RoomCaptureView
    
    // Capture and room builder configuration
    private let captureSessionConfig: RoomCaptureSession.Configuration
    private let roomBuilder: RoomBuilder
    
    // ARSession downloader
    private let downloader: Downloader
    
    // The final scan result
    var finalRoom: CapturedRoom?
    
    // Required functions to conform to NSCoding protocol
    func encode(with coder: NSCoder) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error when initializing RoomCaptureModel")
    }
    
    // Private initializer. Accessed by shared.
    private init() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        downloader = Downloader(session: roomCaptureView.captureSession)
        
        roomCaptureView.captureSession.delegate = self
    }
        
    // Start and stop the capture session. Available from our RoomCaptureScanView.
    func startSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
    
    // Create the final scan result: a CapturedRoom object
    func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {
        if let error {
            print("Error ending capture session; \(error)")
        }
        
        Task {
            finalRoom = try! await roomBuilder.capturedRoom(from: data)
            
            try! await downloader.downloadUsd(name: "parametric", exportOption: .parametric)
            try! await downloader.downloadUsd(name: "mesh", exportOption: .mesh)
        }
    }
    
}
