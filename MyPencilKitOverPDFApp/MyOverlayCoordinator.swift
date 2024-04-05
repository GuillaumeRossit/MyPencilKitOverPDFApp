//
//  MyOverlayCoordinator.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 30/07/2023.
//

import UIKit
import PDFKit
import PencilKit

class MyOverlayCoordinator: NSObject {

    var pageToViewMapping = [MyPDFPage: PKCanvasView]()
    
    func overlayView(for page: PDFPage) -> PKCanvasView? {
        var resultView: PKCanvasView? = nil
        
        guard let page = page as? MyPDFPage else {
            return nil
        }

        if let overlayView = pageToViewMapping[page] {
            resultView = overlayView
        } else {
            let canvasView = PKCanvasView(frame: .zero)
            
            canvasView.drawingPolicy = .anyInput
            MyPDFKitToolPickerModel.shared.toolPicker.addObserver(canvasView)
            canvasView.backgroundColor = UIColor.clear
            pageToViewMapping[page] = canvasView
            resultView = canvasView
        }
        return resultView
    }
}
    
//MARK: - PDFPageOverlayViewProvider

extension MyOverlayCoordinator: PDFPageOverlayViewProvider {

    func pdfView(_ view: PDFView,
                 overlayViewFor page: PDFPage) -> UIView? {
        
        print(" Setup overlay view for a PDFPage")

        var resultView: PKCanvasView? = nil
                
        guard let page = page as? MyPDFPage else {
            return nil
        }

        if let overlayView = pageToViewMapping[page] {
            resultView = overlayView
        } else {

            let canvasView = PKCanvasView(frame: .zero)

            canvasView.drawingPolicy = .anyInput
            MyPDFKitToolPickerModel.shared.toolPicker.addObserver(canvasView)
            canvasView.backgroundColor = UIColor.clear
            pageToViewMapping[page] = canvasView
            resultView = canvasView
        }

        // If we have stored a drawing on the page, set it on the canvas
        if let resultView,
           let drawing = page.popAnnotations(to: resultView),
           drawing.strokes.count > 0 {
            print(" Restore a drawing in a Canvas")
            resultView.drawing = drawing
            page.canvasView = resultView
        }
        
        return resultView
    }
    
    
    func pdfView(_ pdfView: PDFView, willDisplayOverlayView overlayView: UIView,
                 for page: PDFPage) {
        print("willDisplayOverlayView")
        
        guard let page = page as? MyPDFPage else {
            return
        }

        if let drawing = page.drawing,
           let overlayView = pageToViewMapping[page] {

            overlayView.drawingPolicy = .anyInput
            overlayView.backgroundColor = UIColor.clear
            overlayView.drawing = drawing
            page.canvasView = overlayView
            
            overlayView.undoManager?.groupsByEvent = false
            for (index, _) in overlayView.drawing.strokes.enumerated() {
                overlayView.undoManager?.beginUndoGrouping()
                overlayView.undoManager?.registerUndo(withTarget: overlayView,
                                                      handler: {
                    $0.drawing.strokes.remove(at: index)
                    let strokes = $0.drawing.strokes
                    overlayView.drawing.strokes = strokes
                })
                overlayView.undoManager?.endUndoGrouping()
            }
            overlayView.undoManager?.groupsByEvent = true
            
            page.canvasView = overlayView
        }
    }
    
    func pdfView(_ pdfView: PDFView,
                 willEndDisplayingOverlayView overlayView: UIView,
                 for page: PDFPage) {
        print(" 2.1 - Get drawing from a Canvas before it disappears")
        guard let overlayView = overlayView as? PKCanvasView else {
            return
        }
        if let page = page as? MyPDFPage {
            page.drawing = overlayView.drawing
            self.pageToViewMapping.removeValue(forKey: page)
        }
    }
}
