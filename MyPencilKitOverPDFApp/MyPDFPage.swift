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
}
