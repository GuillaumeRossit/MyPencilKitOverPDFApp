//
//  MyPDFPage.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 29/07/2023.
//

import PDFKit
import PencilKit

class MyPDFPage: PDFPage {
    var drawing: PKDrawing?
    var canvasView: PKCanvasView?
    
    func popAnnotations(to thatCanvasView: PKCanvasView) -> PKDrawing? {
        
        let annotations = self.annotations

        var drawing: PKDrawing?

        for annotation in annotations {
            if annotation.type == "Ink",
               let base64EncodedString = annotation.contents,
               let drawingData = Data(base64Encoded: base64EncodedString) {
                do {
                    let retrievedDrawing = try PKDrawing(data: drawingData)
                    self.drawing = retrievedDrawing
                    drawing = retrievedDrawing
                    self.removeAnnotation(annotation)
                } catch {
                    print("\(#function): \(error.localizedDescription)")
                }
            }
        }
        return drawing
    }
}
