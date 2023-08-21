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
        var frames: [ARFrame] = []
        var frameCount = 0
        let requestQueue = DispatchQueue(label: "Request Queue")
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            frameCount &+= 1
             
             // You probably don't need to run barcode detection *every* frame, that could get pretty expensive.
            if shouldSaveFrame() {
                saveFrame(frame: frame)
            }
        }
        
        private func shouldSaveFrame() -> Bool {
            return frameCount % 10 == 0
        }
        
        private func getDocumentDir() -> URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        private func saveFrame(frame: ARFrame) {
            // Perform the request off the main queue to avoid blocking the UI (and the ARSessionDelegate, who's methods are by default called on the main queue).
            requestQueue.async { [unowned self] in
                do {
                    let ciimage = CIImage(cvPixelBuffer: frame.capturedImage) // depth cvPixelBuffer
                    let depthUIImage = UIImage(ciImage: ciimage)
                    let id = UUID().uuidString
                    if let data = depthUIImage.pngData() {
                        let dir = getDocumentDir().appendingPathComponent("frames/")
                        let fileURL = dir.appendingPathComponent("\(id).png")
                        try! data.write(to: fileURL)
                    }
                }
            }
        }
    }
}
