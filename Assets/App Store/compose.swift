#!/usr/bin/env swift

import AppKit

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let languages = ["en", "ja", "zh-Hans", "zh-Hant", "ms"]

/// 6.5" iPhone. Captures live in `Raw/<lang>/` and are written to `<lang>/`.
let canvasSize = NSSize(width: 1242, height: 2688)

struct Copy {
    /// The smaller line above the title.
    let lead: String
    let title: String
}

struct Screenshot {
    let name: String
    var isDark = false
    /// Keyed by language code. A language without copy is skipped.
    let copy: [String: Copy]
}

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1
    )
}

// The greens of the Keynote decks, lightening toward the bottom.
let lightGradient = (top: color(0x6BBE4F), bottom: color(0x8FF189))
let darkGradient = (top: color(0x094706), bottom: color(0x2C7D3A))

let screenshots = [
    Screenshot(name: "01-nearby", copy: [
        "en": Copy(lead: "Glance to Check", title: "Nearby Arrivals"),
        "ja": Copy(lead: "一目でわかる", title: "バスの到着時間"),
        "zh-Hans": Copy(lead: "一眼就能看到", title: "附近巴士到站时间"),
        "zh-Hant": Copy(lead: "一眼就能看到", title: "附近巴士到站時間"),
        "ms": Copy(lead: "Semak Sekilas", title: "Ketibaan Berdekatan")
    ]),
    Screenshot(name: "02-locations", copy: [
        "en": Copy(lead: "Save and Organize", title: "Favorite Bus Stops"),
        "ja": Copy(lead: "よく使うバス停を保存して", title: "より早くアクセス"),
        "zh-Hans": Copy(lead: "保存并整理", title: "常用巴士站"),
        "zh-Hant": Copy(lead: "儲存並整理", title: "常用巴士站"),
        "ms": Copy(lead: "Simpan dan Susun", title: "Perhentian Bas Kegemaran")
    ]),
    Screenshot(name: "03-route", copy: [
        "en": Copy(lead: "Find Your Bus", title: "Bus Service Routes"),
        "ja": Copy(lead: "どこに行くかと答えてくれる", title: "バスルート表示機能"),
        "zh-Hans": Copy(lead: "找到你的巴士", title: "巴士路线"),
        "zh-Hant": Copy(lead: "找到你的巴士", title: "巴士路線"),
        "ms": Copy(lead: "Cari Bas Anda", title: "Laluan Perkhidmatan Bas")
    ]),
    Screenshot(name: "04-search", copy: [
        "en": Copy(lead: "Find and Locate", title: "Bus Stop Directory"),
        "ja": Copy(lead: "簡単に検索できる", title: "バス停のディレクトリ"),
        "zh-Hans": Copy(lead: "轻松查找", title: "巴士站目录"),
        "zh-Hant": Copy(lead: "輕鬆查找", title: "巴士站目錄"),
        "ms": Copy(lead: "Cari dan Temui", title: "Direktori Perhentian Bas")
    ]),
    Screenshot(name: "05-bus-stop", copy: [
        "en": Copy(lead: "See Before You Go", title: "Look Around Bus Stops"),
        "ja": Copy(lead: "行く前に確認できる", title: "バス停の周辺を見渡す"),
        "zh-Hans": Copy(lead: "出发前先看看", title: "巴士站实景预览"),
        "zh-Hant": Copy(lead: "出發前先看看", title: "巴士站實景預覽"),
        "ms": Copy(lead: "Lihat Sebelum Pergi", title: "Lihat Sekeliling Perhentian")
    ]),
    Screenshot(name: "06-dark", isDark: true, copy: [
        "en": Copy(lead: "Live in the Dark", title: "Dark Mode"),
        "ja": Copy(lead: "暗くしたいなら", title: "ダークモード"),
        "zh-Hans": Copy(lead: "夜间也舒适", title: "深色模式"),
        "zh-Hant": Copy(lead: "夜間也舒適", title: "深色模式"),
        "ms": Copy(lead: "Selesa di Waktu Malam", title: "Mod Gelap")
    ])
]

// MARK: - Text

/// SF Pro, falling back to the system's CJK fonts for the language rather than
/// whichever it picks, which would draw Chinese with Japanese glyph forms.
func font(ofSize size: CGFloat, weight: NSFont.Weight, language: String) -> NSFont {
    let system = NSFont.systemFont(ofSize: size, weight: weight)
    let fallback: String? = switch language {
    case "ja": weight >= .heavy ? "HiraginoSans-W8" : "HiraginoSans-W7"
    case "zh-Hans": weight >= .heavy ? "PingFangSC-Semibold" : "PingFangSC-Medium"
    case "zh-Hant": weight >= .heavy ? "PingFangTC-Semibold" : "PingFangTC-Medium"
    default: nil
    }
    guard let fallback else { return system }
    let descriptor = system.fontDescriptor.addingAttributes([
        .cascadeList: [NSFontDescriptor(name: fallback, size: size)]
    ])
    return NSFont(descriptor: descriptor, size: size) ?? system
}

/// One line of text at the largest size up to `size` that fits `maxWidth`.
struct Line {
    let text: String
    let attributes: [NSAttributedString.Key: Any]
    let size: NSSize

    init(_ text: String, size: CGFloat, weight: NSFont.Weight, language: String, maxWidth: CGFloat) {
        var fontSize = size
        var attributes: [NSAttributedString.Key: Any] = [:]
        var lineSize = NSSize.zero
        while fontSize > 10 {
            attributes = [
                .font: font(ofSize: fontSize, weight: weight, language: language),
                .foregroundColor: NSColor.white
            ]
            lineSize = (text as NSString).size(withAttributes: attributes)
            if lineSize.width <= maxWidth { break }
            fontSize -= 2
        }
        self.text = text
        self.attributes = attributes
        self.size = lineSize
        (inkTop, inkBottom) = Line.inkInsets(of: text, attributes: attributes, size: lineSize)
    }

    /// How far below the top of the line box the glyphs actually start and end.
    let inkTop: CGFloat
    let inkBottom: CGFloat

    /// Centering by font metrics leaves the text looking off, since the line box carries
    /// space above the capitals and below the baseline. So the line is rendered once and
    /// the rows its glyphs cover are measured.
    private static func inkInsets(
        of text: String, attributes: [NSAttributedString.Key: Any], size: NSSize
    ) -> (CGFloat, CGFloat) {
        let width = Int(size.width.rounded(.up))
        let height = Int(size.height.rounded(.up))
        guard width > 0, height > 0, let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return (0, size.height) }
        bitmap.size = NSSize(width: width, height: height)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        var opaque = attributes
        opaque[.foregroundColor] = NSColor.black
        (text as NSString).draw(at: .zero, withAttributes: opaque)
        NSGraphicsContext.restoreGraphicsState()

        // Bitmap rows run top to bottom.
        let inked = (0..<height).filter { row in
            (0..<width).contains { column in (bitmap.colorAt(x: column, y: row)?.alphaComponent ?? 0) > 0.1 }
        }
        guard let first = inked.first, let last = inked.last else { return (0, size.height) }
        return (CGFloat(first), CGFloat(last + 1))
    }

    /// Draws the line centered across the canvas, with the top of its line box at `top`.
    func draw(top: CGFloat) {
        (text as NSString).draw(
            at: NSPoint(x: (canvasSize.width - size.width) / 2, y: top - size.height),
            withAttributes: attributes
        )
    }
}

// MARK: - Device frame

func cgImage(of image: NSImage) -> CGImage {
    image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
}

/// Draws `raw` aspect-filled into `rect`.
func drawFilled(_ raw: CGImage, in rect: CGRect, context: CGContext) {
    let rawSize = CGSize(width: raw.width, height: raw.height)
    let scale = max(rect.width / rawSize.width, rect.height / rawSize.height)
    let drawSize = CGSize(width: rawSize.width * scale, height: rawSize.height * scale)
    context.draw(raw, in: CGRect(
        x: rect.midX - drawSize.width / 2,
        y: rect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
    ))
}

let hardwareImage = NSImage(contentsOf: scriptDir.appendingPathComponent("Hardware@2x.png"))!
let displayImage = NSImage(contentsOf: scriptDir.appendingPathComponent("Display@2x.png"))!
let displayCG = cgImage(of: displayImage)
let hardwarePixel = NSSize(width: cgImage(of: hardwareImage).width, height: cgImage(of: hardwareImage).height)
let displayPixel = NSSize(width: displayCG.width, height: displayCG.height)
// The display mask sits centered within the hardware frame.
let displayOrigin = NSPoint(
    x: (hardwarePixel.width - displayPixel.width) / 2,
    y: (hardwarePixel.height - displayPixel.height) / 2
)

/// The capture with the Dynamic Island drawn in, which simulator screenshots leave out.
/// Sized for the 440 by 956 point screen of the iPhone Pro Max, at its scale.
func withDynamicIsland(_ raw: NSImage) -> CGImage {
    let rawCG = cgImage(of: raw)
    let size = NSSize(width: rawCG.width, height: rawCG.height)
    let scale = size.width / 440
    let image = NSImage(size: size)
    image.lockFocus()
    NSGraphicsContext.current!.cgContext.draw(rawCG, in: CGRect(origin: .zero, size: size))
    let island = NSRect(x: (size.width - 125 * scale) / 2, y: size.height - (11 + 37) * scale,
                        width: 125 * scale, height: 37 * scale)
    NSColor.black.setFill()
    NSBezierPath(roundedRect: island, xRadius: island.height / 2, yRadius: island.height / 2).fill()
    image.unlockFocus()
    return cgImage(of: image)
}

/// The capture clipped by the display mask, on a hardware-sized canvas.
func maskedScreen(raw: NSImage) -> NSImage {
    let image = NSImage(size: hardwarePixel)
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let displayRect = CGRect(origin: displayOrigin, size: displayPixel)
    ctx.clip(to: displayRect, mask: displayCG)
    drawFilled(withDynamicIsland(raw), in: displayRect, context: ctx)
    image.unlockFocus()
    return image
}

// MARK: - Composition

func compose(_ shot: Screenshot, language: String) -> Bool {
    guard let copy = shot.copy[language] else { return true }
    let rawURL = scriptDir.appendingPathComponent("Raw").appendingPathComponent(language)
        .appendingPathComponent("\(shot.name).png")
    guard let raw = NSImage(contentsOf: rawURL) else {
        print("missing raw capture: \(rawURL.path)")
        return false
    }

    let image = NSImage(size: canvasSize)
    image.lockFocus()
    draw(shot, copy: copy, language: language, raw: raw)
    image.unlockFocus()
    return write(image, language: language, name: shot.name)
}

func draw(_ shot: Screenshot, copy: Copy, language: String, raw: NSImage) {
    let gradient = shot.isDark ? darkGradient : lightGradient
    NSGradient(starting: gradient.top, ending: gradient.bottom)?
        .draw(in: NSRect(origin: .zero, size: canvasSize), angle: -90)

    // As in the Keynote decks, the device is nearly as wide as the canvas and runs off its
    // bottom, below a band that holds the text. AppKit's origin is bottom-left.
    let deviceWidth: CGFloat = 1132
    let deviceSize = NSSize(width: deviceWidth, height: deviceWidth * hardwarePixel.height / hardwarePixel.width)
    let deviceTop = canvasSize.height - 500
    let deviceRect = NSRect(
        x: ((canvasSize.width - deviceSize.width) / 2).rounded(),
        y: (deviceTop - deviceSize.height).rounded(),
        width: deviceSize.width,
        height: deviceSize.height
    )

    let textWidth = canvasSize.width - 120
    let lead = Line(copy.lead, size: 80, weight: .bold, language: language, maxWidth: textWidth)
    let title = Line(copy.title, size: 112, weight: .heavy, language: language, maxWidth: textWidth)
    let lineGap: CGFloat = 0
    // From the top of the lead's ink to the bottom of the title's.
    let inkHeight = lead.size.height + lineGap + title.inkBottom - lead.inkTop
    // The text's ink is centered in the band between the top of the canvas and the device.
    let inkTop = (canvasSize.height + deviceTop + inkHeight) / 2
    let leadTop = (inkTop + lead.inkTop).rounded()
    lead.draw(top: leadTop)
    title.draw(top: leadTop - lead.size.height - lineGap)

    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
    shadow.shadowBlurRadius = 60
    shadow.shadowOffset = NSSize(width: 0, height: -24)
    shadow.set()
    hardwareImage.draw(in: deviceRect)
    NSGraphicsContext.current?.restoreGraphicsState()
    maskedScreen(raw: raw).draw(in: deviceRect)
}

func write(_ image: NSImage, language: String, name: String) -> Bool {
    // Rasterize at exactly the canvas size in pixels, without alpha, which App Store Connect rejects.
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width), pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false,
        colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 32
    ) else { return false }
    bitmap.size = canvasSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    image.draw(in: NSRect(origin: .zero, size: canvasSize))
    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else { return false }
    let outDir = scriptDir.appendingPathComponent(language)
    try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
    let outURL = outDir.appendingPathComponent("\(name).png")
    do {
        try png.write(to: outURL)
        print("wrote \(language)/\(name).png")
        return true
    } catch {
        print("failed to write \(outURL.path): \(error)")
        return false
    }
}

var allOK = true
for language in languages {
    for shot in screenshots {
        allOK = compose(shot, language: language) && allOK
    }
}
exit(allOK ? 0 : 1)
