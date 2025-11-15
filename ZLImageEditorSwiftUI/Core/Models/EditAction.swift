//
//  EditAction.swift
//  ZLImageEditorSwiftUI
//
//  Adapted from ZLEditorManager.swift
//  Created by SwiftUI Rewrite
//

import Foundation

/// Represents an editing action for undo/redo functionality
public enum EditAction: Equatable {
    case draw(DrawPath)
    case eraser([DrawPath])
    case clip(oldStatus: ClipStatus, newStatus: ClipStatus)
    case mosaic(MosaicPath)
    case filter(oldFilter: Filter, newFilter: Filter)
    case adjust(oldStatus: AdjustStatus, newStatus: AdjustStatus)

    public static func == (lhs: EditAction, rhs: EditAction) -> Bool {
        switch (lhs, rhs) {
        case (.draw(let path1), .draw(let path2)):
            return path1.index == path2.index
        case (.clip(let old1, let new1), .clip(let old2, let new2)):
            return old1 == old2 && new1 == new2
        case (.mosaic(let path1), .mosaic(let path2)):
            return path1.startPoint == path2.startPoint
        case (.filter(let old1, let new1), .filter(let old2, let new2)):
            return old1 == old2 && new1 == new2
        case (.adjust(let old1, let new1), .adjust(let old2, let new2)):
            return old1 == old2 && new1 == new2
        default:
            return false
        }
    }
}
