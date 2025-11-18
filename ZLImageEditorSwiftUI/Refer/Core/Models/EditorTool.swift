//
//  EditorTool.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import Foundation

/// Available editing tools
public enum EditorTool: String, CaseIterable, Identifiable {
    case draw
    case clip
    case imageSticker
    case textSticker
    case mosaic
    case filter
    case adjust

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .draw: return "Draw"
        case .clip: return "Clip"
        case .imageSticker: return "Sticker"
        case .textSticker: return "Text"
        case .mosaic: return "Mosaic"
        case .filter: return "Filter"
        case .adjust: return "Adjust"
        }
    }

    public var iconName: String {
        switch self {
        case .draw: return "pencil.tip.crop.circle"
        case .clip: return "crop"
        case .imageSticker: return "photo.on.rectangle"
        case .textSticker: return "textformat"
        case .mosaic: return "squares.below.rectangle"
        case .filter: return "camera.filters"
        case .adjust: return "slider.horizontal.3"
        }
    }
}
