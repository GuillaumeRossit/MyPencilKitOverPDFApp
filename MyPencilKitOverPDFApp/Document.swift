//
//  Document.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 29/07/2023.
//

import UIKit
import PDFKit

public enum MyPencilKitOverPDFDocumentError: Error {
    case open
}

class Document: UIDocument {
    
    var pdfDocument: PDFDocument?
 
    override func load(fromContents contents: Any,
                       ofType typeName: String?) throws {
        
        print(" 1.1 - Loads document")

        guard let typeName = typeName else {
            throw MyPencilKitOverPDFDocumentError.open
        }
        switch typeName {
        case "com.adobe.pdf":
            if let data = contents as? Data {
                print(" 1.2 - as PDF")
                self.pdfDocument = PDFDocument(data: data)
            } else {
                self.pdfDocument = nil
            }
        default:
            print("loadFromContents: typeName : \(String(describing: typeName))")
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        
        print("contents forType \(typeName)")

        if let pdfDocument = pdfDocument {
            
            // Go through all pages in the document
            for i in 0...pdfDocument.pageCount-1 {
                if let page = pdfDocument.page(at: i) {
                    
                    if let page = (page as? MyPDFPage),
                       let drawing = page.drawing {
                        
                        print(" 2.2 - Get stuff from a PencilKit canvas")
                        
                        let mediaBoxBounds = page.bounds(for: .mediaBox)
                        let mediaBoxHeight = page.bounds(for: .mediaBox).height
                        
                        let userDefinedAnnotationProperties = [MyPDFAnnotation.pdfPageMediaBoxHeightKey:NSNumber(value: mediaBoxHeight)]

                        // Create an annotation of our custom subclass
                        let newAnnotation = MyPDFAnnotation(bounds: mediaBoxBounds,
                                                            forType: .stamp,
                                                            withProperties: userDefinedAnnotationProperties)
                        
                        // Add our custom data
                        do {
                            let codedData = try NSKeyedArchiver.archivedData(withRootObject: drawing,
                                                                             requiringSecureCoding: true)
                            newAnnotation.setValue(codedData,
                                                   forAnnotationKey: PDFAnnotationKey(rawValue: MyPDFAnnotation.drawingDataKey))
                        } catch {
                            print("\(error.localizedDescription)")
                        }

                        // Add our annotation to the page
                        page.addAnnotation(newAnnotation)
                    }
                }
            }
        
            // -- Option #1: Save the document to a data representation
//            if let resultData = pdfDocument.dataRepresentation() {
//                return resultData
//            }
            
            // -- Option #2: Save the document to a data representation and "burn in" annotations
            let options = [PDFDocumentWriteOption.burnInAnnotationsOption: true]
            if let resultData = pdfDocument.dataRepresentation(options: options) {
                return resultData
            }
        }
        
        // Fall through to returning empty data
        return Data()
    }
}

