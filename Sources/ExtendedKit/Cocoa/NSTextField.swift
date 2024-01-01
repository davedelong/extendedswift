//
//  NSTextField.swift
//  ExtendedKit
//
//  Created by Dave DeLong on 12/31/23.
//

import Foundation

#if os(macOS)

import Cocoa

extension NSTextField {
    
    public static func label(_ string: String, verticallyCentered: Bool) -> NSTextField {
        if verticallyCentered == false {
            return NSTextField(labelWithString: string)
        } else {
            return VerticallyCenteredText(labelWithString: string)
        }
    }
    
    public static func text(_ string: String, verticallyCentered: Bool) -> NSTextField {
        if verticallyCentered == false {
            return NSTextField(string: string)
        } else {
            return VerticallyCenteredText(string: string)
        }
    }
    
}

private class VerticallyCenteredText: NSTextField {
    
    override class var cellClass: AnyClass? {
        get { RSVerticallyCenteredTextFieldCell.self }
        set { }
    }
    
}

// From https://github.com/KCreate/RSVerticallyCenteredTextFieldCell/blob/master/RSVerticallyCenteredTextFieldCell.swift
//
// Originally created by Daniel Jalkut on 6/17/06.
// Copyright 2006 Red Sweater Software. All rights reserved.
//
// Rewritten in Swift by Leonard Schuetz on 21.06.15
// Twitter: leni4838
// Web: leonardschuetz.ch

class RSVerticallyCenteredTextFieldCell: NSTextFieldCell {
    private var isEditingOrSelecting = false
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        //Get the parent's idea of where we should draw
        var newRect = super.drawingRect(forBounds: rect)
        
        // When the text field is being edited or selected, we have to turn off the magic because it screws up
        // the configuration of the field editor.  We sneak around this by intercepting selectWithFrame and editWithFrame and sneaking a
        // reduced, centered rect in at the last minute.
        
        if isEditingOrSelecting == false {
            // Get our ideal size for current text
            let textSize = self.cellSize(forBounds: rect)
            
            //Center in the proposed rect
            let heightDelta = newRect.size.height - textSize.height
            if heightDelta > 0 {
                newRect.size.height -= heightDelta
                newRect.origin.y += heightDelta/2
            }
        }
        
        return newRect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let aRect = self.drawingRect(forBounds: rect)
        isEditingOrSelecting = true;
        super.select(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        isEditingOrSelecting = false;
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let aRect = self.drawingRect(forBounds: rect)
        isEditingOrSelecting = true;
        super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
        isEditingOrSelecting = false
    }
}

#endif
