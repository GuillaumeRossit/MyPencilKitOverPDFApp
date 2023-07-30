//
//  MyOverlayCoordinator.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 30/07/2023.
//

import UIKit
import PDFKit
import PencilKit

class MyOverlayCoordinator: NSObject, PDFPageOverlayViewProvider {

    var pageToViewMapping = [MyPDFPage: PKCanvasView]()

    func pdfView(_ view: PDFView,
                 overlayViewFor page: PDFPage) -> UIView? {
        
        print(" Setup overlay view for a PDFPage")

        var resultView: PKCanvasView? = nil
        
        guard let page = page as? MyPDFPage else {
            return nil
        }

        if let overlayView = self.pageToViewMapping[page] {
            resultView = overlayView
        } else {
            let canvasView = PKCanvasView(frame: .zero)
            canvasView.drawingPolicy = .anyInput
            MyPDFKitToolPickerModel.shared.toolPicker.addObserver(canvasView)
            canvasView.backgroundColor = UIColor.clear
            self.pageToViewMapping[page] = canvasView
            resultView = canvasView
        }

        // If we have stored a drawing on the page, set it on the canvas
        if let drawing = page.drawing {
            print(" Restore a drawing in a Canvas")
            resultView?.drawing = drawing
            page.canvasView = resultView
        }
        
        return resultView
    }
    
    func pdfView(_ pdfView: PDFView, willDisplayOverlayView overlayView: UIView,
                 for page: PDFPage) {
        print("willDisplayOverlayView")

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
