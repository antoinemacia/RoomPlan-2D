//
//  Downloader.swift
//  RoomPlan 2D
//
//  Created by Antoine Macia on 15/8/2023.
//

import RoomPlan
import ARKit

class Downloader  {
    private let captureSession: RoomCaptureSession
    private let documentsDir: URL
    private let coordinator: Coordinator

    init(session: RoomCaptureSession) {
        captureSession = session
        documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        coordinator = Coordinator()
        session.arSession.delegate = coordinator
            }
    
    func downloadUsd(name: String, exportOption: CapturedRoom.USDExportOptions) async throws -> Void {
        let url = documentsDir.appendingPathComponent("\(name).usdz")
        let finalRoom = RoomCaptureModel.shared.finalRoom!
        try! finalRoom.export(to: url, exportOptions: [exportOption])
    }
    
    func downloadFrames(name: String) async throws -> Void {
        try! await coordinator.downloadFrames(name: name)
    }
    
    private func createDirIfNeeded(dirName: String) {
        let dir = documentsDir.appendingPathComponent("frames/")
        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func downloadFrames() throws -> Void {
//        for frame in coordinator.frames {
//            let ciimage = CIImage(cvPixelBuffer: frame.capturedImage) // depth cvPixelBuffer
//            let depthUIImage = UIImage(ciImage: ciimage)
//            let id = UUID().uuidString
//            if let data = depthUIImage.pngData() {
//                let filename = documentsDir.appendingPathComponent("frames/\(id).png")
//                try? data.write(to: filename)
//            }
//        }
//    }
    
    final class Coordinator: NSObject, ARSessionDelegate {
        var frameCount = 0
        let requestQueue = DispatchQueue(label: "Request Queue")
        var frames: [ARFrame] = []
        var sessionConfigured = false
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            configureARSession(session: session)
            frameCount &+= 1
            
            if shouldSaveFrame() {
                Task {
                    saveFrame(frame: frame)
                }
            }
        }
        
        private func configureARSession(session: ARSession) {
            if(sessionConfigured) { return }
            
//            let config = session.configuration
//            let format = ARWorldTrackingConfiguration.supportedVideoFormats.first(where: { $0.is } )
//            if(format != nil) {
//                config!.videoFormat = format!
//            }
//
            sessionConfigured = true
        }
        
        func downloadFrames(name: String) async throws -> Void {
            frames.forEach { frame in saveFrame(frame: frame) }
        }
        
        private func captureFrame(session: ARSession) async throws -> Void {
            let frame = try await session.captureHighResolutionFrame()
            frames.append(frame)
        }
        
        private func shouldSaveFrame() -> Bool {
            return frameCount % 30 == 0
        }
        
        private func getDocumentDir() -> URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        private func saveFrame(frame: ARFrame) {
            let ciimage = CIImage(cvPixelBuffer: frame.capturedImage) // depth cvPixelBuffer
            let depthUIImage = UIImage(ciImage: ciimage)
            let id = UUID().uuidString
            if let data = depthUIImage.pngData() {
                let dir = getDocumentDir().appendingPathComponent("frames2/")
                try! FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
                
                let fileURL = dir.appendingPathComponent("\(id).png")
                try! data.write(to: fileURL)
            }
        }
    }
}
