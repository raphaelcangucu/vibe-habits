#!/usr/bin/env swift

import AppKit
import Foundation

struct Palette {
    let accent: NSColor
    let glow: NSColor
}

struct ScreenshotSpec {
    let file: String
    let eyebrow: String
    let headline: String
    let body: String
    let palette: Palette
}

let arguments = CommandLine.arguments
guard arguments.count == 5 else {
    fputs("Usage: frame_store_screenshots.swift SOURCE_DIR OUTPUT_DIR LANGUAGE DEVICE\n", stderr)
    exit(2)
}

let sourceDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
let outputDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)
let language = arguments[3]
let device = arguments[4]

let blue = Palette(
    accent: NSColor(calibratedRed: 0.02, green: 0.43, blue: 0.96, alpha: 1),
    glow: NSColor(calibratedRed: 0.23, green: 0.72, blue: 1.00, alpha: 1)
)
let purple = Palette(
    accent: NSColor(calibratedRed: 0.45, green: 0.19, blue: 0.93, alpha: 1),
    glow: NSColor(calibratedRed: 0.72, green: 0.52, blue: 1.00, alpha: 1)
)
let orange = Palette(
    accent: NSColor(calibratedRed: 0.96, green: 0.38, blue: 0.08, alpha: 1),
    glow: NSColor(calibratedRed: 1.00, green: 0.72, blue: 0.26, alpha: 1)
)
let teal = Palette(
    accent: NSColor(calibratedRed: 0.00, green: 0.50, blue: 0.46, alpha: 1),
    glow: NSColor(calibratedRed: 0.30, green: 0.88, blue: 0.72, alpha: 1)
)
let green = Palette(
    accent: NSColor(calibratedRed: 0.08, green: 0.58, blue: 0.30, alpha: 1),
    glow: NSColor(calibratedRed: 0.48, green: 0.88, blue: 0.48, alpha: 1)
)

let specs: [ScreenshotSpec]
switch language {
case "pt-BR":
    specs = [
        .init(
            file: "01-habits.png",
            eyebrow: "COMECE HOJE",
            headline: "Hábitos que viram\nparte da sua vida",
            body: "Metas simples. Progresso claro.\nUm dia de cada vez.",
            palette: blue
        ),
        .init(
            file: "02-insights.png",
            eyebrow: "PROGRESSO VISÍVEL",
            headline: "Sua consistência,\nem números",
            body: "Acompanhe sequências, ritmo e evolução\nsem complicação.",
            palette: purple
        ),
        .init(
            file: "03-reminder.png",
            eyebrow: "NO SEU RITMO",
            headline: "Lembretes que\ntrabalham por você",
            body: "Escolha o horário e mantenha o foco\nno que importa.",
            palette: orange
        ),
        .init(
            file: "04-private-backup.png",
            eyebrow: "PRIVACIDADE PRIMEIRO",
            headline: "Seus hábitos.\nSeus dados.",
            body: "Backup em JSON, sob seu controle\ne sem conta obrigatória.",
            palette: teal
        ),
        .init(
            file: "05-feed.png",
            eyebrow: "CADA PASSO CONTA",
            headline: "Pequenas vitórias.\nGrandes mudanças.",
            body: "Relembre o caminho e celebre\nsua evolução.",
            palette: green
        )
    ]
default:
    specs = [
        .init(
            file: "01-habits.png",
            eyebrow: "START TODAY",
            headline: "Habits that become\npart of your life",
            body: "Simple goals. Clear progress.\nOne day at a time.",
            palette: blue
        ),
        .init(
            file: "02-insights.png",
            eyebrow: "PROGRESS YOU CAN SEE",
            headline: "Your consistency,\nin numbers",
            body: "Track streaks, momentum and growth\nwithout the complexity.",
            palette: purple
        ),
        .init(
            file: "03-reminder.png",
            eyebrow: "ON YOUR SCHEDULE",
            headline: "Reminders that\nwork for you",
            body: "Choose the right time and stay focused\non what matters.",
            palette: orange
        ),
        .init(
            file: "04-private-backup.png",
            eyebrow: "PRIVACY FIRST",
            headline: "Your habits.\nYour data.",
            body: "Portable JSON backups, under your control.\nNo account required.",
            palette: teal
        ),
        .init(
            file: "05-feed.png",
            eyebrow: "EVERY STEP COUNTS",
            headline: "Small wins.\nBig change.",
            body: "Look back on the journey and celebrate\nyour progress.",
            palette: green
        )
    ]
}

let isPad = device == "iPad-13"
let canvasSize = isPad ? NSSize(width: 2064, height: 2752) : NSSize(width: 1320, height: 2868)
let sideInset: CGFloat = isPad ? 150 : 96
let screenWidth: CGFloat = isPad ? 1500 : 1000
let deviceTop: CGFloat = isPad ? 630 : 630
let bezel: CGFloat = isPad ? 22 : 18
let cornerRadius: CGFloat = isPad ? 62 : 72

let navy = NSColor(calibratedRed: 0.045, green: 0.075, blue: 0.14, alpha: 1)
let secondaryText = NSColor(calibratedRed: 0.23, green: 0.27, blue: 0.35, alpha: 1)

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func rectFromTop(x: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> NSRect {
    NSRect(x: x, y: canvasSize.height - top - height, width: width, height: height)
}

func drawText(
    _ text: String,
    rect: NSRect,
    font: NSFont,
    color: NSColor,
    lineSpacing: CGFloat = 0,
    kern: CGFloat = 0
) {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    style.lineSpacing = lineSpacing
    style.lineBreakMode = .byWordWrapping
    (text as NSString).draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style,
            .kern: kern
        ]
    )
}

func fillRoundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func drawBackground(_ palette: Palette) {
    let paleAccent = palette.accent.blended(withFraction: 0.88, of: .white) ?? .white
    let paleGlow = palette.glow.blended(withFraction: 0.91, of: .white) ?? .white
    NSGradient(colors: [paleAccent, .white, paleGlow])!
        .draw(in: NSRect(origin: .zero, size: canvasSize), angle: -38)

    let topOrb = rectFromTop(
        x: canvasSize.width * 0.64,
        top: isPad ? -180 : -120,
        width: canvasSize.width * 0.62,
        height: canvasSize.width * 0.62
    )
    palette.glow.withAlphaComponent(0.12).setFill()
    NSBezierPath(ovalIn: topOrb).fill()

    let lowerOrb = NSRect(
        x: -canvasSize.width * 0.18,
        y: -canvasSize.width * 0.12,
        width: canvasSize.width * 0.62,
        height: canvasSize.width * 0.62
    )
    palette.accent.withAlphaComponent(0.07).setFill()
    NSBezierPath(ovalIn: lowerOrb).fill()
}

func drawBrand() {
    let pill = rectFromTop(
        x: sideInset,
        top: isPad ? 72 : 78,
        width: isPad ? 338 : 318,
        height: isPad ? 68 : 64
    )

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.07)
    shadow.shadowBlurRadius = 22
    shadow.shadowOffset = NSSize(width: 0, height: -6)
    shadow.set()
    fillRoundedRect(pill, radius: pill.height / 2, color: NSColor.white.withAlphaComponent(0.90))
    NSGraphicsContext.restoreGraphicsState()

    let label = rectFromTop(
        x: pill.minX + (isPad ? 26 : 23),
        top: isPad ? 88 : 93,
        width: pill.width - 40,
        height: 40
    )
    drawText(
        "✓  VIBE HABITS",
        rect: label,
        font: .systemFont(ofSize: isPad ? 27 : 25, weight: .bold),
        color: navy,
        kern: 1.8
    )
}

for spec in specs {
    let inputURL = sourceDirectory.appendingPathComponent(spec.file)
    guard let screenshot = NSImage(contentsOf: inputURL), screenshot.size.width > 0 else {
        fputs("Missing screenshot: \(inputURL.path)\n", stderr)
        exit(1)
    }

    let pixelWidth = Int(canvasSize.width)
    let pixelHeight = Int(canvasSize.height)
    guard let bitmapContext = CGContext(
        data: nil,
        width: pixelWidth,
        height: pixelHeight,
        bitsPerComponent: 8,
        bytesPerRow: pixelWidth * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else {
        fputs("Could not create bitmap for \(spec.file)\n", stderr)
        exit(1)
    }

    let drawingContext = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
    let previousContext = NSGraphicsContext.current
    NSGraphicsContext.current = drawingContext

    drawBackground(spec.palette)
    drawBrand()

    let eyebrowWidth = isPad ? 470 : 390
    let eyebrow = rectFromTop(
        x: sideInset,
        top: isPad ? 182 : 176,
        width: CGFloat(eyebrowWidth),
        height: isPad ? 54 : 50
    )
    fillRoundedRect(
        eyebrow,
        radius: eyebrow.height / 2,
        color: spec.palette.accent.withAlphaComponent(0.11)
    )
    drawText(
        spec.eyebrow,
        rect: rectFromTop(
            x: eyebrow.minX + (isPad ? 25 : 21),
            top: isPad ? 194 : 188,
            width: eyebrow.width - 40,
            height: 31
        ),
        font: .systemFont(ofSize: isPad ? 23 : 21, weight: .bold),
        color: spec.palette.accent,
        kern: 1.3
    )

    drawText(
        spec.headline,
        rect: rectFromTop(
            x: sideInset,
            top: isPad ? 255 : 248,
            width: canvasSize.width - sideInset * 2,
            height: isPad ? 205 : 195
        ),
        font: .systemFont(ofSize: isPad ? 74 : 66, weight: .heavy),
        color: navy,
        lineSpacing: isPad ? -6 : -5,
        kern: -1.2
    )

    drawText(
        spec.body,
        rect: rectFromTop(
            x: sideInset,
            top: isPad ? 475 : 466,
            width: canvasSize.width - sideInset * 2,
            height: isPad ? 105 : 108
        ),
        font: .systemFont(ofSize: isPad ? 30 : 28, weight: .medium),
        color: secondaryText,
        lineSpacing: 4
    )

    let scale = screenWidth / screenshot.size.width
    let screenHeight = screenshot.size.height * scale
    let screenX = (canvasSize.width - screenWidth) / 2
    let screenRect = rectFromTop(x: screenX, top: deviceTop + bezel, width: screenWidth, height: screenHeight)
    let deviceRect = rectFromTop(
        x: screenX - bezel,
        top: deviceTop,
        width: screenWidth + bezel * 2,
        height: screenHeight + bezel * 2
    )

    let glowRect = deviceRect.insetBy(dx: isPad ? -46 : -36, dy: isPad ? -46 : -36)
    fillRoundedRect(
        glowRect,
        radius: cornerRadius + 30,
        color: spec.palette.accent.withAlphaComponent(0.08)
    )

    NSGraphicsContext.saveGraphicsState()
    let deviceShadow = NSShadow()
    deviceShadow.shadowColor = navy.withAlphaComponent(0.24)
    deviceShadow.shadowBlurRadius = isPad ? 55 : 46
    deviceShadow.shadowOffset = NSSize(width: 0, height: -16)
    deviceShadow.set()
    fillRoundedRect(deviceRect, radius: cornerRadius, color: navy)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(
        roundedRect: screenRect,
        xRadius: cornerRadius - bezel,
        yRadius: cornerRadius - bezel
    ).addClip()
    NSGraphicsContext.current?.imageInterpolation = .high
    screenshot.draw(in: screenRect, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.25).setStroke()
    let rim = NSBezierPath(roundedRect: deviceRect, xRadius: cornerRadius, yRadius: cornerRadius)
    rim.lineWidth = isPad ? 3 : 2
    rim.stroke()

    NSGraphicsContext.current = previousContext

    guard let renderedImage = bitmapContext.makeImage() else {
        fputs("Could not finalize \(spec.file)\n", stderr)
        exit(1)
    }
    let bitmap = NSBitmapImageRep(cgImage: renderedImage)
    guard let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 0.94]) else {
        fputs("Could not render \(spec.file)\n", stderr)
        exit(1)
    }

    let outputName = "\(device)-\(spec.file)"
    try pngData.write(to: outputDirectory.appendingPathComponent(outputName), options: .atomic)
    print("Rendered \(outputName)")
}
