//
//  MyPDFKitToolPickerModel.swift
//  MyPencilKitOverPDFApp
//
//  Created by rossit on 30/07/2023.
//

import PencilKit


class MyPDFKitToolPickerModel: NSObject {
    
    let toolPicker = PKToolPicker()
        
    static let shared = MyPDFKitToolPickerModel()
    
    override init() {
        
        super.init()
        
        self.setToolToYellowHighlighter()
    }
    
    func setToolToYellowHighlighter() {
        let highlighterYellowColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.7)
        self.toolPicker.selectedTool = PKInkingTool(.marker, color: highlighterYellowColor, width: 25.0)
    }
}
