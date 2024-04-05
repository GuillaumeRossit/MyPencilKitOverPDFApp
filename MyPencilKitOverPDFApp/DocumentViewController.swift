//
//  DocumentViewController.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 29/07/2023.
//

import UIKit
import PDFKit


extension PDFView {
    func panWithTwoFingers() {
        for view in self.subviews {
            if let subView = view as? UIScrollView {
                subView.panGestureRecognizer.minimumNumberOfTouches = 2
            }
        }
    }
}

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var pdfView: PDFView?
    
    var pdfDocumentURL: URL?
    
    var document: Document?
    
    var overlayCoordinator: MyOverlayCoordinator = MyOverlayCoordinator()
    
    var openOrSave: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pdfUrl = Bundle.main.url(forResource: "lorem", withExtension: "pdf") else {
            return
        }
        
        self.pdfDocumentURL = pdfUrl
        
        print("   1 - Loads document")

        self.document = Document(fileURL: pdfUrl)
        
        self.pdfView?.displayDirection = .vertical
        
        self.pdfView?.pageOverlayViewProvider = self.overlayCoordinator
        self.pdfView?.isInMarkupMode = true
        self.pdfView?.panWithTwoFingers()
    }
    
    @IBAction func openSaveTouched() {
        if self.openOrSave {
            print("   -> Save touched !")
            self.save()
            self.saveButton?.setTitle("Open", for: .normal)
        } else {
            print("   -> Open touched !")
            self.open()
            self.saveButton?.setTitle("Save", for: .normal)
        }
        self.openOrSave.toggle()
    }
    
    private func open() {
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                print(" 1.3 - Document opened")
                self.document?.pdfDocument?.delegate = self // PDFDocumentDelegate
                self.pdfView?.document = self.document?.pdfDocument
                self.displaysDocument()
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    private func save() {
        
        print("   2 - Saves document")

        guard let url = self.pdfDocumentURL,
        let document = self.document else {
            return
        }
        
        self.pdfView?.document = nil
        
        print("Will then try to save at URL : \(url)")
        
        document.close(completionHandler: { (success) in
            if success {
                document.save(to: url,
                              for: .forOverwriting,
                              completionHandler: { (success) in
                    print(" 2.4 - Saved at \(url)")
                })
            } else {
                print("Sorry, error !")
            }
        })
    }
    
    private func displaysDocument() {
        guard let document = self.pdfView?.document,
              let page: MyPDFPage = document.page(at: 0) as? MyPDFPage else {
            return
        }
        // Setup canvas for MyPDFPage
        self.setupCanvasView(at: page)
        
        guard let pageCanvasView = page.canvasView else {
            return
        }
        MyPDFKitToolPickerModel.shared.toolPicker.setVisible(true, forFirstResponder: pageCanvasView)
        pageCanvasView.becomeFirstResponder()
    }
    
    private func setupCanvasView(at page: MyPDFPage) {
        if page.canvasView == nil,
           let storedCanvas = self.overlayCoordinator.pageToViewMapping[page] {
            page.canvasView = storedCanvas
        } else {
            // create canvasView
            page.canvasView = self.overlayCoordinator.overlayView(for: page)
        }
    }
}

extension DocumentViewController: PDFDocumentDelegate {
    public func classForPage() -> AnyClass {
        print(" 1.4 - Request custom page type?")
        return MyPDFPage.self
    }
    
    public func `class`(forAnnotationType annotationType: String) -> AnyClass {
        switch annotationType {
        case MyPDFAnnotation.drawingDataKey:
            return MyPDFAnnotation.self
        default:
            return PDFAnnotation.self
        }
    }
}
