#!/usr/bin/env swift

import Foundation
import AppKit
import CoreGraphics

func generateAppIcon() {
    let sizes: [(size: Int, name: String)] = [
        (1024, "AppIcon"),
        (180, "AppIcon-60@3x"),
        (120, "AppIcon-60@2x"),
        (87, "AppIcon-29@3x"),
        (58, "AppIcon-29@2x"),
        (80, "AppIcon-40@2x"),
        (120, "AppIcon-40@3x"),
        (76, "AppIcon-76"),
        (152, "AppIcon-76@2x"),
        (167, "AppIcon-83.5@2x")
    ]

    let outputPath = "./AppIconImages"
    try? FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: true)

    for sizeInfo in sizes {
        let size = CGFloat(sizeInfo.size)
        let image = createIconImage(size: size)

        if let pngData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: pngData),
           let data = bitmap.representation(using: .png, properties: [:]) {
            let filePath = "\(outputPath)/\(sizeInfo.name).png"
            try? data.write(to: URL(fileURLWithPath: filePath))
            print("Generated: \(filePath)")
        }
    }
}

func createIconImage(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    // Background gradient (blue)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0),
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
    ] as CFArray

    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

    // Calculate dimensions
    let padding = size * 0.2
    let gridSize = size - (padding * 2)
    let squareSize = gridSize / 4.5
    let spacing = squareSize * 0.3

    // Draw 3x3 grid of rounded squares
    for row in 0..<3 {
        for col in 0..<3 {
            let x = padding + CGFloat(col) * (squareSize + spacing)
            let y = padding + CGFloat(row) * (squareSize + spacing)

            // Determine color based on position (gradient effect)
            let opacity = 0.7 + (Double(row * 3 + col) / 9.0) * 0.3
            let color = NSColor(white: 1.0, alpha: opacity)

            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            let cornerRadius = squareSize * 0.25

            let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            color.setFill()
            path.fill()
        }
    }

    // Add subtle checkmark overlay on last square
    let lastX = padding + 2 * (squareSize + spacing)
    let lastY = padding + 2 * (squareSize + spacing)

    context.setLineWidth(size * 0.012)
    context.setStrokeColor(CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0))
    context.setLineCap(.round)
    context.setLineJoin(.round)

    let checkStartX = lastX + squareSize * 0.25
    let checkStartY = lastY + squareSize * 0.5
    let checkMidX = lastX + squareSize * 0.45
    let checkMidY = lastY + squareSize * 0.7
    let checkEndX = lastX + squareSize * 0.75
    let checkEndY = lastY + squareSize * 0.3

    context.beginPath()
    context.move(to: CGPoint(x: checkStartX, y: checkStartY))
    context.addLine(to: CGPoint(x: checkMidX, y: checkMidY))
    context.addLine(to: CGPoint(x: checkEndX, y: checkEndY))
    context.strokePath()

    image.unlockFocus()

    return image
}

// Run the generator
generateAppIcon()
print("✅ App icons generated successfully!")
