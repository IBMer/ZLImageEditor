# ZLImageEditor SwiftUI 重构技术设计文档

## 📋 项目概述

### 目标
将现有的 UIKit 实现的 ZLImageEditor 重构为基于 **SwiftUI + Core Image** 的现代化图片编辑器，保持所有功能完整性的同时，采用最新的 Swift 和 SwiftUI 技术栈。

### 核心原则
- **完整功能对等**：100% 实现原 ZLImageEditor 的 7 大核心功能
- **代码复用**：最大化复用现有成熟代码（图像处理、算法逻辑）
- **现代化架构**：MVVM + Repository Pattern + Observation Framework
- **编码规范**：严格遵守 DRY, SRP, OCP, ISP, DIP, KISS
- **组件化**：View 模块化拆分，单一职责，易于维护

---

## 🛠 技术栈

### Swift & SwiftUI 版本
- **Swift 6.0+** (最新稳定版)
- **SwiftUI 5.0+** (iOS 17+)
- **Observation Framework** (`@Observable` 替代 `ObservableObject`)
- **Swift Concurrency** (async/await, actor)

### 核心框架
```swift
// UI 层
import SwiftUI

// 图像处理
import CoreImage
import CoreImage.CIFilterBuiltins
import Accelerate  // 高性能图像缩放 (复用现有代码)

// 图形渲染
import CoreGraphics
```

### 最低支持版本
- **iOS 17.0+** (充分利用最新 SwiftUI 特性)

---

## 🏗 架构设计

### 整体架构模式

```
┌─────────────────────────────────────────────────────────────┐
│                         SwiftUI Views                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ToolbarView│ │DrawView │ │ClipView │ │FilterView│ ...   │
│  └─────┬────┘ └─────┬────┘ └─────┬────┘ └─────┬────┘       │
└────────┼────────────┼────────────┼────────────┼────────────┘
         │            │            │            │
         └────────────┴────────────┴────────────┘
                      │
         ┌────────────▼────────────┐
         │    ViewModels Layer     │
         │  (@Observable classes)  │
         ├─────────────────────────┤
         │ • ImageEditorViewModel  │
         │ • DrawingViewModel      │
         │ • ClipViewModel         │
         │ • FilterViewModel       │
         │ • ...                   │
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │    Services Layer       │
         ├─────────────────────────┤
         │ • ImageProcessService   │ ◄── 复用现有代码
         │ • FilterService         │ ◄── 复用现有代码
         │ • UndoRedoManager       │ ◄── 适配现有逻辑
         │ • DrawPathRenderer      │ ◄── 复用渲染逻辑
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │     Models Layer        │
         ├─────────────────────────┤
         │ • DrawPath              │ ◄── 直接复用
         │ • ClipStatus            │ ◄── 直接复用
         │ • Filter                │ ◄── 直接复用
         │ • StickerState          │ ◄── 适配为 value type
         └─────────────────────────┘
```

### 设计模式应用

#### 1. MVVM (Model-View-ViewModel)
```swift
// View: 纯 UI 声明
struct ImageEditorView: View {
    @State private var viewModel = ImageEditorViewModel()
    // ...
}

// ViewModel: 业务逻辑 + 状态管理
@Observable
class ImageEditorViewModel {
    var currentImage: UIImage
    var editHistory: [EditAction]
    // ...
}

// Model: 数据模型
struct DrawPath: Identifiable, Codable {
    let id: UUID
    var points: [CGPoint]
    // ...
}
```

#### 2. Repository Pattern
```swift
protocol ImageProcessingRepository {
    func applyFilter(_ filter: Filter, to image: UIImage) async -> UIImage
    func renderDrawPaths(_ paths: [DrawPath], on image: UIImage) -> UIImage
}

actor ImageProcessingService: ImageProcessingRepository {
    // 线程安全的图像处理
}
```

#### 3. Strategy Pattern (滤镜系统)
```swift
protocol FilterStrategy {
    func apply(to image: CIImage) -> CIImage
}

struct ChromeFilter: FilterStrategy { /* ... */ }
struct NashvilleFilter: FilterStrategy { /* ... */ }
```

#### 4. Command Pattern (Undo/Redo)
```swift
protocol EditCommand {
    func execute()
    func undo()
}

struct DrawCommand: EditCommand { /* ... */ }
struct ClipCommand: EditCommand { /* ... */ }
```

---

## 📦 模块设计

### 模块划分原则
- **单一职责**：每个模块只负责一个编辑功能
- **高内聚低耦合**：模块间通过协议通信
- **可独立测试**：每个模块可单独测试

### 核心模块列表

```
ZLImageEditorSwiftUI/
├── Core/                          # 核心层
│   ├── Models/                    # 数据模型 (复用)
│   │   ├── DrawPath.swift         ◄── 直接复用
│   │   ├── ClipStatus.swift       ◄── 直接复用
│   │   ├── AdjustStatus.swift     ◄── 直接复用
│   │   ├── Filter.swift           ◄── 直接复用
│   │   ├── MosaicPath.swift       ◄── 直接复用
│   │   └── StickerModel.swift     ◄── 重构为 value type
│   │
│   ├── Services/                  # 业务服务
│   │   ├── ImageProcessingService.swift
│   │   ├── FilterService.swift
│   │   ├── DrawPathRenderer.swift     ◄── 复用渲染逻辑
│   │   └── UndoRedoManager.swift      ◄── 适配现有实现
│   │
│   └── Extensions/                # 扩展 (复用)
│       ├── UIImage+Resize.swift       ◄── 直接复用 (Accelerate)
│       ├── UIImage+Orientation.swift  ◄── 直接复用
│       └── CIImage+Extensions.swift
│
├── Features/                      # 功能模块
│   ├── Editor/                    # 主编辑器
│   │   ├── ViewModels/
│   │   │   └── ImageEditorViewModel.swift
│   │   └── Views/
│   │       ├── ImageEditorView.swift          # 主容器
│   │       ├── ImageCanvasView.swift          # 图片画布
│   │       └── BottomToolbarView.swift        # 工具栏
│   │
│   ├── Drawing/                   # 绘制模块
│   │   ├── ViewModels/
│   │   │   └── DrawingViewModel.swift
│   │   └── Views/
│   │       ├── DrawingCanvasView.swift        # 绘制画布
│   │       ├── ColorPickerView.swift          # 颜色选择
│   │       └── BrushSizeSlider.swift          # 画笔大小
│   │
│   ├── Clip/                      # 裁剪模块
│   │   ├── ViewModels/
│   │   │   └── ClipViewModel.swift
│   │   └── Views/
│   │       ├── ClipEditorView.swift           # 裁剪编辑器
│   │       ├── ClipOverlayView.swift          # 裁剪蒙层
│   │       ├── ClipGridView.swift             # 网格线
│   │       └── AspectRatioPickerView.swift    # 比例选择
│   │
│   ├── Filter/                    # 滤镜模块
│   │   ├── ViewModels/
│   │   │   └── FilterViewModel.swift
│   │   ├── Views/
│   │   │   ├── FilterPickerView.swift         # 滤镜选择
│   │   │   └── FilterThumbnailCell.swift      # 缩略图
│   │   └── Filters/
│   │       ├── FilterProtocol.swift
│   │       ├── BuiltInFilters.swift           ◄── 复用滤镜定义
│   │       └── CustomFilters.swift            ◄── 复用自定义滤镜
│   │
│   ├── Mosaic/                    # 马赛克模块
│   │   ├── ViewModels/
│   │   │   └── MosaicViewModel.swift
│   │   └── Views/
│   │       └── MosaicCanvasView.swift
│   │
│   ├── Sticker/                   # 贴纸模块
│   │   ├── ViewModels/
│   │   │   └── StickerViewModel.swift
│   │   ├── Views/
│   │   │   ├── StickerContainerView.swift
│   │   │   ├── TextStickerView.swift
│   │   │   └── ImageStickerView.swift
│   │   └── Gestures/
│   │       └── StickerGestureModifier.swift   # 手势处理
│   │
│   └── Adjust/                    # 调整模块
│       ├── ViewModels/
│       │   └── AdjustViewModel.swift
│       └── Views/
│           ├── AdjustmentPanelView.swift
│           └── AdjustmentSlider.swift
│
├── Utilities/                     # 工具类
│   ├── Configuration.swift        ◄── 适配现有配置
│   ├── Constants.swift
│   └── Helpers.swift
│
└── Resources/                     # 资源文件
    └── Assets.xcassets
```

---

## 🎨 核心模块详细设计

### 1. 主编辑器模块 (Editor)

#### ImageEditorViewModel
```swift
@Observable
final class ImageEditorViewModel {
    // MARK: - State
    var originalImage: UIImage
    var currentImage: UIImage
    var selectedTool: EditorTool = .none
    var canUndo: Bool = false
    var canRedo: Bool = false

    // MARK: - Sub-ViewModels (依赖注入)
    var drawingVM: DrawingViewModel
    var clipVM: ClipViewModel
    var filterVM: FilterViewModel
    var mosaicVM: MosaicViewModel
    var stickerVM: StickerViewModel
    var adjustVM: AdjustViewModel

    // MARK: - Services
    private let imageService: ImageProcessingService
    private let undoRedoManager: UndoRedoManager

    // MARK: - Methods
    func selectTool(_ tool: EditorTool) { /* ... */ }
    func undo() { /* ... */ }
    func redo() { /* ... */ }
    func buildFinalImage() async -> UIImage { /* 复用现有合成逻辑 */ }
}

enum EditorTool: String, CaseIterable {
    case draw, clip, imageSticker, textSticker, mosaic, filter, adjust
}
```

#### ImageEditorView (主容器)
```swift
struct ImageEditorView: View {
    @State private var viewModel: ImageEditorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部工具栏
                TopToolbarView(
                    onCancel: handleCancel,
                    onUndo: viewModel.undo,
                    onRedo: viewModel.redo,
                    canUndo: viewModel.canUndo,
                    canRedo: viewModel.canRedo
                )

                // 画布区域
                ImageCanvasView(viewModel: viewModel)

                // 底部工具栏
                BottomToolbarView(
                    selectedTool: $viewModel.selectedTool,
                    onDone: handleDone
                )
            }

            // 工具面板 (条件显示)
            toolPanelOverlay
        }
    }

    @ViewBuilder
    private var toolPanelOverlay: some View {
        switch viewModel.selectedTool {
        case .draw:
            DrawingPanelView(viewModel: viewModel.drawingVM)
        case .filter:
            FilterPickerView(viewModel: viewModel.filterVM)
        // ...
        default:
            EmptyView()
        }
    }
}
```

#### ImageCanvasView (图片画布)
```swift
struct ImageCanvasView: View {
    @Bindable var viewModel: ImageEditorViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 基础图片层
                Image(uiImage: viewModel.currentImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                // 绘制层 (条件显示)
                if viewModel.selectedTool == .draw {
                    DrawingCanvasView(viewModel: viewModel.drawingVM)
                }

                // 马赛克层
                if viewModel.selectedTool == .mosaic {
                    MosaicCanvasView(viewModel: viewModel.mosaicVM)
                }

                // 贴纸容器层
                StickerContainerView(viewModel: viewModel.stickerVM)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
```

---

### 2. 绘制模块 (Drawing)

#### DrawingViewModel
```swift
@Observable
final class DrawingViewModel {
    // MARK: - State
    var paths: [DrawPath] = []           // 复用 ZLDrawPath
    var currentColor: Color = .red
    var brushSize: CGFloat = 5.0
    var isEraserMode: Bool = false

    // MARK: - Services
    private let pathRenderer: DrawPathRenderer  // 复用现有渲染逻辑

    // MARK: - Methods
    func addPath(_ path: DrawPath) { /* ... */ }
    func removePath(at index: Int) { /* ... */ }
    func renderDrawing(on image: UIImage) -> UIImage {
        // 复用 ZLDrawPath 的渲染逻辑
        return pathRenderer.render(paths: paths, on: image)
    }
}
```

#### DrawingCanvasView
```swift
struct DrawingCanvasView: View {
    @Bindable var viewModel: DrawingViewModel
    @State private var currentPath: [CGPoint] = []

    var body: some View {
        Canvas { context, size in
            // 渲染已完成的路径
            for path in viewModel.paths {
                renderPath(path, in: context)
            }

            // 渲染当前正在绘制的路径
            if !currentPath.isEmpty {
                renderCurrentPath(in: context)
            }
        }
        .gesture(drawGesture)
    }

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                currentPath.append(value.location)
            }
            .onEnded { _ in
                let drawPath = DrawPath(
                    points: currentPath,
                    color: viewModel.currentColor,
                    lineWidth: viewModel.brushSize,
                    willDelete: viewModel.isEraserMode
                )
                viewModel.addPath(drawPath)
                currentPath = []
            }
    }

    private func renderPath(_ path: DrawPath, in context: GraphicsContext) {
        // 复用 ZLDrawPath 的平滑曲线算法
        let smoothPath = path.smoothPath()  // Catmull-Rom 样条
        context.stroke(
            smoothPath,
            with: .color(path.color),
            lineWidth: path.lineWidth
        )
    }
}
```

#### ColorPickerView (颜色选择器)
```swift
struct ColorPickerView: View {
    @Binding var selectedColor: Color
    let colors: [Color]  // 从配置读取

    var body: some View {
        HStack(spacing: 12) {
            ForEach(colors, id: \.self) { color in
                ColorCircleButton(
                    color: color,
                    isSelected: color == selectedColor,
                    action: { selectedColor = color }
                )
            }
        }
        .padding()
    }
}

struct ColorCircleButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    }
                }
        }
    }
}
```

---

### 3. 裁剪模块 (Clip)

#### ClipViewModel
```swift
@Observable
final class ClipViewModel {
    // MARK: - State
    var originalImage: UIImage
    var clipStatus: ClipStatus          // 复用现有模型
    var selectedRatio: ClipRatio?
    var angle: Angle = .zero
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero

    // MARK: - Computed
    var clipFrame: CGRect {
        calculateClipFrame()  // 复用现有计算逻辑
    }

    // MARK: - Methods
    func applyClip() -> UIImage {
        // 复用现有裁剪算法
        return clipStatus.clipImage(originalImage)
    }

    func rotate() { /* 90度旋转 */ }
    func reset() { /* 重置 */ }

    private func calculateClipFrame() -> CGRect {
        // 复用 ZLClipImageViewController 的计算逻辑
    }
}
```

#### ClipEditorView
```swift
struct ClipEditorView: View {
    @Bindable var viewModel: ClipViewModel

    var body: some View {
        ZStack {
            // 图片层
            Image(uiImage: viewModel.originalImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .rotationEffect(viewModel.angle)

            // 裁剪蒙层 + 网格
            ClipOverlayView(clipFrame: viewModel.clipFrame)
            ClipGridView(clipFrame: viewModel.clipFrame)

            // 裁剪框手柄
            ClipHandlesView(
                clipFrame: viewModel.clipFrame,
                onDrag: handleDrag
            )
        }
        .gesture(panGesture)
        .gesture(magnificationGesture)
    }
}

struct ClipOverlayView: View {
    let clipFrame: CGRect

    var body: some View {
        // 半透明黑色蒙层 + 裁剪区域镂空
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.5))
            )
            context.blendMode = .destinationOut
            context.fill(
                Path(clipFrame),
                with: .color(.white)
            )
        }
    }
}
```

---

### 4. 滤镜模块 (Filter)

#### FilterViewModel
```swift
@Observable
final class FilterViewModel {
    // MARK: - State
    var originalImage: UIImage
    var selectedFilter: Filter = .normal    // 复用 ZLFilter
    var thumbnails: [FilterThumbnail] = []

    // MARK: - Services
    private let filterService: FilterService

    // MARK: - Initialization
    init(image: UIImage, filterService: FilterService) {
        self.originalImage = image
        self.filterService = filterService

        Task {
            await generateThumbnails()
        }
    }

    // MARK: - Methods
    func applyFilter(_ filter: Filter) -> UIImage {
        // 复用 ZLFilter 的应用逻辑
        return filterService.apply(filter, to: originalImage)
    }

    private func generateThumbnails() async {
        // 复用现有缩略图生成逻辑
        let thumbSize = CGSize(width: 200, height: 200)
        let resized = originalImage.resize_vI(thumbSize)  // Accelerate 加速

        for filter in Filter.allCases {
            let filtered = filterService.apply(filter, to: resized)
            thumbnails.append(FilterThumbnail(filter: filter, image: filtered))
        }
    }
}

struct FilterThumbnail: Identifiable {
    let id = UUID()
    let filter: Filter
    let image: UIImage
}
```

#### FilterPickerView
```swift
struct FilterPickerView: View {
    @Bindable var viewModel: FilterViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.thumbnails) { thumbnail in
                    FilterThumbnailCell(
                        thumbnail: thumbnail,
                        isSelected: thumbnail.filter == viewModel.selectedFilter,
                        action: { viewModel.selectedFilter = thumbnail.filter }
                    )
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}

struct FilterThumbnailCell: View {
    let thumbnail: FilterThumbnail
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(uiImage: thumbnail.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 3)
                        }
                    }

                Text(thumbnail.filter.rawValue)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .blue : .white)
            }
        }
    }
}
```

---

### 5. 马赛克模块 (Mosaic)

#### MosaicViewModel
```swift
@Observable
final class MosaicViewModel {
    // MARK: - State
    var paths: [MosaicPath] = []         // 复用 ZLMosaicPath
    var mosaicImage: UIImage?
    var lineWidth: CGFloat = 25.0

    // MARK: - Services
    private let imageService: ImageProcessingService

    // MARK: - Initialization
    init(originalImage: UIImage, imageService: ImageProcessingService) {
        self.imageService = imageService

        Task {
            // 复用现有马赛克生成逻辑
            self.mosaicImage = await generateMosaicImage(from: originalImage)
        }
    }

    // MARK: - Methods
    func addPath(_ path: MosaicPath) { /* ... */ }

    private func generateMosaicImage(from image: UIImage) async -> UIImage {
        // 复用 ZLEditImageViewController 的马赛克生成逻辑
        let scale = 8 * image.size.width / UIScreen.main.bounds.width
        return await imageService.applyPixelate(to: image, scale: scale)
    }
}
```

#### MosaicCanvasView
```swift
struct MosaicCanvasView: View {
    @Bindable var viewModel: MosaicViewModel
    @State private var currentPath: [CGPoint] = []

    var body: some View {
        Canvas { context, size in
            // 使用遮罩渲染马赛克
            if let mosaicImage = viewModel.mosaicImage {
                // 创建遮罩路径
                var maskPath = Path()
                for path in viewModel.paths {
                    maskPath.addPath(Path(path.points))
                }

                // 应用遮罩显示马赛克
                context.clip(to: maskPath)
                context.draw(
                    Image(uiImage: mosaicImage),
                    in: CGRect(origin: .zero, size: size)
                )
            }
        }
        .gesture(mosaicGesture)
    }
}
```

---

### 6. 贴纸模块 (Sticker)

#### StickerViewModel
```swift
@Observable
final class StickerViewModel {
    // MARK: - State
    var stickers: [StickerModel] = []
    var selectedSticker: StickerModel?

    // MARK: - Methods
    func addTextSticker(text: String, color: Color, font: UIFont) {
        let sticker = StickerModel.text(
            id: UUID(),
            text: text,
            color: color,
            font: font,
            transform: .identity
        )
        stickers.append(sticker)
    }

    func addImageSticker(image: UIImage) {
        let sticker = StickerModel.image(
            id: UUID(),
            image: image,
            transform: .identity
        )
        stickers.append(sticker)
    }

    func updateTransform(for id: UUID, transform: CGAffineTransform) {
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[index].transform = transform
    }

    func deleteSticker(_ id: UUID) {
        stickers.removeAll { $0.id == id }
    }
}

// 重构为 value type
enum StickerModel: Identifiable {
    case text(id: UUID, text: String, color: Color, font: UIFont, transform: CGAffineTransform)
    case image(id: UUID, image: UIImage, transform: CGAffineTransform)

    var id: UUID {
        switch self {
        case .text(let id, _, _, _, _): return id
        case .image(let id, _, _): return id
        }
    }

    var transform: CGAffineTransform {
        get {
            switch self {
            case .text(_, _, _, _, let transform): return transform
            case .image(_, _, let transform): return transform
            }
        }
        set {
            switch self {
            case .text(let id, let text, let color, let font, _):
                self = .text(id: id, text: text, color: color, font: font, transform: newValue)
            case .image(let id, let image, _):
                self = .image(id: id, image: image, transform: newValue)
            }
        }
    }
}
```

#### StickerContainerView
```swift
struct StickerContainerView: View {
    @Bindable var viewModel: StickerViewModel

    var body: some View {
        ZStack {
            ForEach(viewModel.stickers) { sticker in
                StickerView(
                    sticker: sticker,
                    isSelected: viewModel.selectedSticker?.id == sticker.id,
                    onTap: { viewModel.selectedSticker = sticker },
                    onTransformChange: { transform in
                        viewModel.updateTransform(for: sticker.id, transform: transform)
                    }
                )
            }
        }
    }
}

struct StickerView: View {
    let sticker: StickerModel
    let isSelected: Bool
    let onTap: () -> Void
    let onTransformChange: (CGAffineTransform) -> Void

    @State private var currentTransform: CGAffineTransform
    @GestureState private var gestureTransform: CGAffineTransform = .identity

    init(sticker: StickerModel, isSelected: Bool, onTap: @escaping () -> Void, onTransformChange: @escaping (CGAffineTransform) -> Void) {
        self.sticker = sticker
        self.isSelected = isSelected
        self.onTap = onTap
        self.onTransformChange = onTransformChange
        self._currentTransform = State(initialValue: sticker.transform)
    }

    var body: some View {
        content
            .transformEffect(currentTransform.concatenating(gestureTransform))
            .overlay {
                if isSelected {
                    stickerBorder
                }
            }
            .onTapGesture(perform: onTap)
            .gesture(combinedGesture)
    }

    @ViewBuilder
    private var content: some View {
        switch sticker {
        case .text(_, let text, let color, let font, _):
            Text(text)
                .font(Font(font))
                .foregroundColor(color)
        case .image(_, let image, _):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }

    private var stickerBorder: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .foregroundColor(.blue)
    }

    private var combinedGesture: some Gesture {
        // 复用 ZLBaseStickerView 的手势逻辑
        SimultaneousGesture(
            dragGesture,
            SimultaneousGesture(
                magnificationGesture,
                rotationGesture
            )
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($gestureTransform) { value, state, _ in
                state = CGAffineTransform(translationX: value.translation.width, y: value.translation.height)
            }
            .onEnded { value in
                currentTransform = currentTransform.translatedBy(x: value.translation.width, y: value.translation.height)
                onTransformChange(currentTransform)
            }
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .updating($gestureTransform) { value, state, _ in
                state = state.scaledBy(x: value.magnification, y: value.magnification)
            }
            .onEnded { value in
                currentTransform = currentTransform.scaledBy(x: value.magnification, y: value.magnification)
                onTransformChange(currentTransform)
            }
    }

    private var rotationGesture: some Gesture {
        RotateGesture()
            .updating($gestureTransform) { value, state, _ in
                state = state.rotated(by: value.rotation.radians)
            }
            .onEnded { value in
                currentTransform = currentTransform.rotated(by: value.rotation.radians)
                onTransformChange(currentTransform)
            }
    }
}
```

---

### 7. 调整模块 (Adjust)

#### AdjustViewModel
```swift
@Observable
final class AdjustViewModel {
    // MARK: - State
    var adjustStatus: AdjustStatus      // 复用现有模型
    var brightness: Float = 0.0
    var contrast: Float = 1.0
    var saturation: Float = 1.0

    // MARK: - Services
    private let imageService: ImageProcessingService

    // MARK: - Methods
    func applyAdjustments(to image: UIImage) -> UIImage {
        // 复用现有调整逻辑
        return imageService.applyColorControls(
            to: image,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation
        )
    }
}
```

#### AdjustmentPanelView
```swift
struct AdjustmentPanelView: View {
    @Bindable var viewModel: AdjustViewModel
    @State private var selectedTool: AdjustTool = .brightness

    var body: some View {
        VStack(spacing: 0) {
            // 工具选择
            AdjustToolPickerView(selectedTool: $selectedTool)

            // 滑块
            AdjustmentSlider(
                value: bindingForTool(selectedTool),
                range: rangeForTool(selectedTool),
                label: selectedTool.rawValue
            )
        }
        .background(.ultraThinMaterial)
    }

    private func bindingForTool(_ tool: AdjustTool) -> Binding<Float> {
        switch tool {
        case .brightness: return $viewModel.brightness
        case .contrast: return $viewModel.contrast
        case .saturation: return $viewModel.saturation
        }
    }

    private func rangeForTool(_ tool: AdjustTool) -> ClosedRange<Float> {
        switch tool {
        case .brightness: return -0.33...0.33
        case .contrast: return 0.5...2.5
        case .saturation: return 0...2
        }
    }
}

enum AdjustTool: String, CaseIterable {
    case brightness = "亮度"
    case contrast = "对比度"
    case saturation = "饱和度"
}

struct AdjustmentSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range)
                .tint(.blue)
        }
        .padding()
    }
}
```

---

### 8. Undo/Redo 系统

#### UndoRedoManager
```swift
actor UndoRedoManager {
    // MARK: - State
    private var actions: [EditAction] = []
    private var redoActions: [EditAction] = []

    var canUndo: Bool {
        !actions.isEmpty
    }

    var canRedo: Bool {
        !redoActions.isEmpty
    }

    // MARK: - Methods
    func record(_ action: EditAction) {
        actions.append(action)
        redoActions.removeAll()
    }

    func undo() -> EditAction? {
        guard let action = actions.popLast() else { return nil }
        redoActions.append(action)
        return action
    }

    func redo() -> EditAction? {
        guard let action = redoActions.popLast() else { return nil }
        actions.append(action)
        return action
    }

    func reset() {
        actions.removeAll()
        redoActions.removeAll()
    }
}

// 复用并扩展 ZLEditorAction
enum EditAction {
    case draw(DrawPath)
    case eraser([DrawPath])
    case clip(oldStatus: ClipStatus, newStatus: ClipStatus)
    case sticker(oldState: StickerModel?, newState: StickerModel?)
    case mosaic(MosaicPath)
    case filter(oldFilter: Filter, newFilter: Filter)
    case adjust(oldStatus: AdjustStatus, newStatus: AdjustStatus)
}
```

---

## 🔄 复用策略

### 直接复用的代码 (无需修改)

#### 1. 数据模型
```swift
// ✅ 直接复用
Sources/General/ZLPaths.swift                    → Core/Models/DrawPath.swift
Sources/General/ZLClipStatus.swift               → Core/Models/ClipStatus.swift
Sources/General/ZLAdjustStatus.swift             → Core/Models/AdjustStatus.swift
Sources/General/ZLFilter.swift                   → Features/Filter/Filters/Filter.swift
```

#### 2. 图像处理扩展
```swift
// ✅ 直接复用 (Accelerate 加速)
Sources/Extensions/UIImage+ZLImageEditor.swift   → Core/Extensions/UIImage+Resize.swift

关键方法:
- func resize_vI(_ size: CGSize) -> UIImage?     // vImage 加速缩放
- func fixOrientation() -> UIImage               // 方向修正
- func compress(to maxSize: Int) -> UIImage      // 智能压缩
```

#### 3. 滤镜定义
```swift
// ✅ 直接复用
Sources/General/ZLFilter.swift

保留所有16种滤镜:
- Normal, Chrome, Fade, Instant, Process, Transfer
- Tone, Linear, Sepia, Mono, Noir, Tonal
- Clarendon, Nashville, 1977, Toaster
```

### 适配后复用的代码

#### 1. 绘制路径渲染
```swift
// 原代码: ZLDrawPath (UIKit 渲染)
// 适配: 提取渲染逻辑到 Service

// Before (UIKit):
extension ZLDrawPath {
    func drawPath() -> UIImage {
        UIGraphicsImageRenderer.zl.renderImage(size: size) { context in
            // ...
        }
    }
}

// After (SwiftUI Service):
class DrawPathRenderer {
    func render(paths: [DrawPath], on image: UIImage) -> UIImage {
        // 复用原有渲染逻辑
        UIGraphicsImageRenderer(size: image.size).image { context in
            image.draw(at: .zero)
            for path in paths {
                renderSinglePath(path, in: context.cgContext)
            }
        }
    }

    private func renderSinglePath(_ path: DrawPath, in context: CGContext) {
        // 完全复用 ZLDrawPath 的平滑曲线算法
        let smoothPoints = path.smoothPath()  // Catmull-Rom
        // ...
    }
}
```

#### 2. 裁剪计算逻辑
```swift
// 原代码: ZLClipImageViewController (复杂的坐标计算)
// 适配: 提取计算逻辑到 ViewModel

// 复用的核心方法:
- calculateClipRect()
- calculateMaxClipRect()
- resetContainerViewFrame()
- clipImage()
```

#### 3. Undo/Redo 管理器
```swift
// 原代码: ZLEditorManager (基于 Delegate)
// 适配: 使用 Actor 实现线程安全

// Before:
class ZLEditorManager {
    weak var delegate: ZLEditorManagerDelegate?
    // ...
}

// After:
actor UndoRedoManager {
    // 保持相同的栈逻辑
    // 使用 async/await 替代 delegate
}
```

### 完全重写的部分

#### 1. UI 层
```swift
// 原代码: UIViewController + UIView
// 新代码: SwiftUI Views

// 重写原因:
// - SwiftUI 声明式 UI 完全不同
// - 不再使用 Frame 布局，改用 GeometryReader
// - 手势系统 API 差异大
```

#### 2. 状态管理
```swift
// 原代码: 属性 + Delegate 回调
// 新代码: @Observable + @Bindable

// 重写原因:
// - 现代化的响应式架构
// - 双向绑定更简洁
// - 自动处理 UI 更新
```

---

## 📐 编码规范实施

### 1. DRY (Don't Repeat Yourself)
```swift
// ❌ 重复代码
struct DrawingCanvasView: View {
    // 重复的渲染逻辑...
}
struct MosaicCanvasView: View {
    // 重复的渲染逻辑...
}

// ✅ 提取共用组件
protocol PathRenderer {
    func render(in context: GraphicsContext)
}

struct CanvasView<Renderer: PathRenderer>: View {
    let renderer: Renderer
    // 统一的渲染逻辑
}
```

### 2. SRP (Single Responsibility Principle)
```swift
// ❌ 违反 SRP
class ImageEditorViewModel {
    func applyFilter() { /* 滤镜逻辑 */ }
    func renderDrawing() { /* 绘制逻辑 */ }
    func cropImage() { /* 裁剪逻辑 */ }
    func saveImage() { /* 存储逻辑 */ }
    // 职责过多
}

// ✅ 遵守 SRP
class ImageEditorViewModel {
    let filterVM: FilterViewModel          // 负责滤镜
    let drawingVM: DrawingViewModel        // 负责绘制
    let clipVM: ClipViewModel              // 负责裁剪
    // 每个 ViewModel 单一职责
}
```

### 3. OCP (Open-Closed Principle)
```swift
// ❌ 违反 OCP
class FilterService {
    func apply(filter: Filter, to image: UIImage) -> UIImage {
        switch filter {
        case .chrome: /* ... */
        case .fade: /* ... */
        // 添加新滤镜需要修改此方法
        }
    }
}

// ✅ 遵守 OCP
protocol FilterStrategy {
    func apply(to image: CIImage) -> CIImage
}

class FilterService {
    private var strategies: [Filter: FilterStrategy] = [:]

    func register(filter: Filter, strategy: FilterStrategy) {
        strategies[filter] = strategy  // 扩展无需修改现有代码
    }
}
```

### 4. ISP (Interface Segregation Principle)
```swift
// ❌ 违反 ISP
protocol StickerDelegate {
    func stickerDidTap()
    func stickerDidMove()
    func stickerDidRotate()
    func stickerDidScale()
    func stickerDidDelete()
    // 强制实现所有方法
}

// ✅ 遵守 ISP
protocol StickerTapDelegate {
    func stickerDidTap()
}

protocol StickerTransformDelegate {
    func stickerDidMove()
    func stickerDidRotate()
    func stickerDidScale()
}

// 按需实现
```

### 5. DIP (Dependency Inversion Principle)
```swift
// ❌ 违反 DIP
class ImageEditorViewModel {
    let filterService = FilterService()  // 依赖具体实现
}

// ✅ 遵守 DIP
protocol ImageProcessingRepository {
    func applyFilter(_ filter: Filter, to image: UIImage) async -> UIImage
}

class ImageEditorViewModel {
    private let imageRepository: ImageProcessingRepository  // 依赖抽象

    init(imageRepository: ImageProcessingRepository) {
        self.imageRepository = imageRepository
    }
}
```

### 6. KISS (Keep It Simple, Stupid)
```swift
// ❌ 过度复杂
func calculateClipFrame() -> CGRect {
    let intermediateValue1 = /* 复杂计算 */
    let intermediateValue2 = /* 复杂计算 */
    // 10 行嵌套计算...
}

// ✅ 简单清晰
func calculateClipFrame() -> CGRect {
    let containerSize = calculateContainerSize()
    let aspectRatio = selectedRatio?.value ?? 1.0
    return CGRect(
        origin: calculateOrigin(for: containerSize),
        size: calculateSize(for: containerSize, aspectRatio: aspectRatio)
    )
}
// 拆分成小函数,每个函数职责单一
```

### 7. View 模块化原则

#### 最大行数限制
- **View**: ≤ 150 行
- **ViewModel**: ≤ 300 行
- **Service**: ≤ 200 行

#### 拆分策略
```swift
// ❌ 单一大 View (300+ 行)
struct ImageEditorView: View {
    var body: some View {
        VStack {
            // 顶部工具栏 50 行
            // 画布区域 100 行
            // 底部工具栏 50 行
            // 弹出面板 100 行
        }
    }
}

// ✅ 模块化拆分
struct ImageEditorView: View {
    var body: some View {
        VStack {
            TopToolbarView(/* ... */)          // 独立组件
            ImageCanvasView(/* ... */)         // 独立组件
            BottomToolbarView(/* ... */)       // 独立组件
        }
        .overlay { toolPanelOverlay }          // 独立计算属性
    }

    @ViewBuilder
    private var toolPanelOverlay: some View {
        // 条件渲染逻辑
    }
}

// 每个组件独立文件, ≤ 100 行
```

---

## 🗂 完整文件结构

```
ZLImageEditorSwiftUI/
├── App/
│   ├── ZLImageEditorSwiftUIApp.swift
│   └── ContentView.swift (Demo)
│
├── Core/
│   ├── Models/
│   │   ├── DrawPath.swift              ◄── 复用
│   │   ├── MosaicPath.swift            ◄── 复用
│   │   ├── ClipStatus.swift            ◄── 复用
│   │   ├── ClipRatio.swift             ◄── 复用
│   │   ├── AdjustStatus.swift          ◄── 复用
│   │   ├── Filter.swift                ◄── 复用
│   │   ├── StickerModel.swift          ◄── 重构
│   │   └── EditAction.swift            ◄── 扩展
│   │
│   ├── Services/
│   │   ├── ImageProcessingService.swift
│   │   ├── FilterService.swift
│   │   ├── DrawPathRenderer.swift      ◄── 提取渲染逻辑
│   │   └── UndoRedoManager.swift       ◄── Actor 实现
│   │
│   ├── Extensions/
│   │   ├── UIImage+Resize.swift        ◄── 复用 (Accelerate)
│   │   ├── UIImage+Orientation.swift   ◄── 复用
│   │   ├── Color+Hex.swift
│   │   └── CGAffineTransform+Extensions.swift
│   │
│   └── Utilities/
│       ├── Configuration.swift         ◄── 适配
│       ├── Constants.swift
│       └── Helpers.swift
│
├── Features/
│   ├── Editor/
│   │   ├── ViewModels/
│   │   │   └── ImageEditorViewModel.swift
│   │   └── Views/
│   │       ├── ImageEditorView.swift
│   │       ├── ImageCanvasView.swift
│   │       ├── TopToolbarView.swift
│   │       └── BottomToolbarView.swift
│   │
│   ├── Drawing/
│   │   ├── ViewModels/
│   │   │   └── DrawingViewModel.swift
│   │   └── Views/
│   │       ├── DrawingCanvasView.swift
│   │       ├── DrawingPanelView.swift
│   │       ├── ColorPickerView.swift
│   │       └── BrushSizeSlider.swift
│   │
│   ├── Clip/
│   │   ├── ViewModels/
│   │   │   └── ClipViewModel.swift
│   │   └── Views/
│   │       ├── ClipEditorView.swift
│   │       ├── ClipCanvasView.swift
│   │       ├── ClipOverlayView.swift
│   │       ├── ClipGridView.swift
│   │       ├── ClipHandlesView.swift
│   │       └── AspectRatioPickerView.swift
│   │
│   ├── Filter/
│   │   ├── ViewModels/
│   │   │   └── FilterViewModel.swift
│   │   ├── Views/
│   │   │   ├── FilterPickerView.swift
│   │   │   └── FilterThumbnailCell.swift
│   │   └── Filters/
│   │       ├── FilterProtocol.swift
│   │       ├── BuiltInFilters.swift    ◄── 复用
│   │       └── CustomFilters.swift     ◄── 复用
│   │
│   ├── Mosaic/
│   │   ├── ViewModels/
│   │   │   └── MosaicViewModel.swift
│   │   └── Views/
│   │       ├── MosaicCanvasView.swift
│   │       └── MosaicPanelView.swift
│   │
│   ├── Sticker/
│   │   ├── ViewModels/
│   │   │   └── StickerViewModel.swift
│   │   └── Views/
│   │       ├── StickerContainerView.swift
│   │       ├── StickerView.swift
│   │       ├── TextStickerView.swift
│   │       ├── ImageStickerView.swift
│   │       ├── TextInputView.swift
│   │       └── Gestures/
│   │           └── StickerGestureModifier.swift
│   │
│   └── Adjust/
│       ├── ViewModels/
│       │   └── AdjustViewModel.swift
│       └── Views/
│           ├── AdjustmentPanelView.swift
│           ├── AdjustToolPickerView.swift
│           └── AdjustmentSlider.swift
│
├── Resources/
│   └── Assets.xcassets
│
└── Tests/
    ├── ViewModelTests/
    ├── ServiceTests/
    └── ModelTests/
```

---

## 🚀 开发计划

### Phase 1: 基础架构 (Week 1)
- [x] 项目结构搭建
- [ ] 核心模型复用 (DrawPath, ClipStatus, Filter 等)
- [ ] 服务层实现 (ImageProcessingService, FilterService)
- [ ] UndoRedoManager (Actor 实现)
- [ ] 配置系统适配

### Phase 2: 主编辑器 (Week 1-2)
- [ ] ImageEditorViewModel
- [ ] ImageEditorView (主容器)
- [ ] ImageCanvasView (画布)
- [ ] TopToolbarView (Undo/Redo/Cancel)
- [ ] BottomToolbarView (工具选择)

### Phase 3: 核心功能模块 (Week 2-3)

#### 3.1 绘制模块
- [ ] DrawingViewModel
- [ ] DrawingCanvasView (Canvas API + 手势)
- [ ] ColorPickerView
- [ ] BrushSizeSlider
- [ ] 平滑曲线算法复用

#### 3.2 裁剪模块
- [ ] ClipViewModel (复用计算逻辑)
- [ ] ClipEditorView
- [ ] ClipOverlayView (蒙层 + 镂空)
- [ ] ClipGridView (网格线)
- [ ] ClipHandlesView (8个手柄)
- [ ] AspectRatioPickerView

#### 3.3 滤镜模块
- [ ] FilterViewModel
- [ ] FilterPickerView (横向滚动)
- [ ] FilterThumbnailCell
- [ ] 滤镜复用 (16 种)
- [ ] 缩略图异步生成

### Phase 4: 高级功能 (Week 3)

#### 4.1 马赛克模块
- [ ] MosaicViewModel
- [ ] MosaicCanvasView (遮罩渲染)
- [ ] 像素化算法复用

#### 4.2 贴纸模块
- [ ] StickerViewModel
- [ ] StickerContainerView
- [ ] TextStickerView
- [ ] ImageStickerView
- [ ] 组合手势实现 (Drag + Pinch + Rotate)
- [ ] TextInputView (输入界面)

#### 4.3 调整模块
- [ ] AdjustViewModel
- [ ] AdjustmentPanelView
- [ ] AdjustToolPickerView
- [ ] AdjustmentSlider (三种调整)

### Phase 5: 集成与优化 (Week 4)
- [ ] 最终图片合成逻辑
- [ ] 性能优化 (异步处理、缓存)
- [ ] 内存管理优化
- [ ] 错误处理
- [ ] 代码审查 (编码规范检查)

### Phase 6: 测试与文档 (Week 4)
- [ ] 单元测试
- [ ] UI 测试
- [ ] 性能测试
- [ ] API 文档
- [ ] 使用示例

---

## 🔍 技术挑战与解决方案

### 挑战 1: SwiftUI Canvas 性能
**问题**: 大量路径绘制时可能掉帧

**解决方案**:
1. 使用 `TimelineView` 控制刷新率
2. 路径简化算法 (Douglas-Peucker)
3. 离屏渲染已完成路径
4. 增量渲染策略

```swift
struct OptimizedDrawingCanvas: View {
    @State private var cachedImage: UIImage?

    var body: some View {
        ZStack {
            // 已完成的路径缓存为图片
            if let cached = cachedImage {
                Image(uiImage: cached)
            }

            // 只渲染当前路径
            Canvas { context, size in
                renderCurrentPath(in: context)
            }
        }
    }
}
```

### 挑战 2: 复杂手势识别
**问题**: SwiftUI 同时识别拖动、缩放、旋转

**解决方案**:
使用 `SimultaneousGesture` + `GestureState`

```swift
var combinedGesture: some Gesture {
    SimultaneousGesture(
        dragGesture,
        SimultaneousGesture(magnifyGesture, rotateGesture)
    )
}
```

### 挑战 3: 大图内存管理
**问题**: 多层编辑导致内存暴涨

**解决方案**:
1. 分层渲染,只在需要时合成
2. 使用 `autoreleasepool`
3. 及时释放中间结果
4. 懒加载滤镜缩略图

```swift
func buildFinalImage() async -> UIImage {
    await withCheckedContinuation { continuation in
        autoreleasepool {
            let base = currentImage
            let withDrawing = drawingVM.renderDrawing(on: base)
            let withMosaic = mosaicVM.renderMosaic(on: withDrawing)
            let final = stickerVM.renderStickers(on: withMosaic)
            continuation.resume(returning: final)
        }
    }
}
```

### 挑战 4: 状态同步
**问题**: 多个 ViewModel 间状态同步

**解决方案**:
使用 `@Observable` + Combine

```swift
@Observable
class ImageEditorViewModel {
    var currentImage: UIImage {
        didSet {
            // 自动传播到子 ViewModel
            filterVM.originalImage = currentImage
            adjustVM.originalImage = currentImage
        }
    }
}
```

---

## 📊 性能目标

### 响应性能
- **工具切换**: < 100ms
- **滤镜预览**: < 500ms
- **绘制响应**: 60fps
- **裁剪拖动**: 60fps
- **贴纸手势**: 60fps

### 内存使用
- **基础占用**: < 100MB
- **编辑 4K 图**: < 500MB
- **峰值内存**: < 800MB

### 启动性能
- **冷启动**: < 1s
- **图片加载**: < 500ms
- **滤镜初始化**: < 1s (后台异步)

---

## ✅ 验收标准

### 功能完整性
- ✅ 7 大核心功能 100% 实现
- ✅ 所有 ZLImageEditor 功能对等
- ✅ 配置系统完全迁移

### 代码质量
- ✅ 无 SwiftLint 警告
- ✅ 代码覆盖率 > 70%
- ✅ 所有 View < 150 行
- ✅ 所有 ViewModel < 300 行

### 性能达标
- ✅ 所有操作 60fps
- ✅ 内存占用达标
- ✅ 无内存泄漏

### 用户体验
- ✅ 手势流畅自然
- ✅ 无明显卡顿
- ✅ 错误提示友好

---

## 🎯 总结

本技术设计文档定义了 ZLImageEditor SwiftUI 重构的完整方案:

1. **最大化复用**: 图像处理、算法逻辑、数据模型直接复用
2. **现代化架构**: MVVM + Observation + Actor
3. **严格规范**: DRY, SRP, OCP, ISP, DIP, KISS
4. **模块化设计**: View 拆分，单一职责
5. **渐进式开发**: 4 周完成，功能对等

### 核心优势
- ✅ 保持原有性能和稳定性
- ✅ 代码更清晰易维护
- ✅ 支持最新 iOS 特性
- ✅ 为未来 Metal 优化预留空间

---

**文档版本**: v1.0
**创建日期**: 2025-11-15
**作者**: Claude + User
**状态**: 待评审 → 开始编码
