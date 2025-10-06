#!/usr/bin/env swift

import Foundation
import AppKit
import CoreGraphics

func generateAppIcons() {
    let sizes = [1024, 180, 120, 87, 58, 80, 76, 152, 167]

    let outputPath = "./AppIconImages"
    try? FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: true)

    for size in sizes {
        if let cgImage = createIconCGImage(size: size) {
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
            if let tiffData = nsImage.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                let filePath = "\(outputPath)/AppIcon-\(size).png"
                try? pngData.write(to: URL(fileURLWithPath: filePath))
                print("Generated: \(filePath) (\(size)x\(size))")
            }
        }
    }
}

func createIconCGImage(size: Int) -> CGImage? {
    let width = size
    let height = size
    let bitsPerComponent = 8
    let bytesPerRow = width * 4
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return nil
    }

    let cgSize = CGFloat(size)

    // Background gradient (blue)
    let colors = [
        CGColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0),
        CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
    ] as CFArray

    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: cgSize), end: CGPoint(x: cgSize, y: 0), options: [])

    // Calculate dimensions
    let padding = cgSize * 0.2
    let gridSize = cgSize - (padding * 2)
    let squareSize = gridSize / 4.5
    let spacing = squareSize * 0.3

    // Draw 3x3 grid of rounded squares
    for row in 0..<3 {
        for col in 0..<3 {
            let x = padding + CGFloat(col) * (squareSize + spacing)
            let y = padding + CGFloat(row) * (squareSize + spacing)

            // Determine color based on position (gradient effect)
            let opacity = 0.7 + (Double(row * 3 + col) / 9.0) * 0.3
            context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: opacity))

            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            let cornerRadius = squareSize * 0.25

            let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
            context.addPath(path)
            context.fillPath()
        }
    }

    // Add subtle checkmark overlay on last square
    let lastX = padding + 2 * (squareSize + spacing)
    let lastY = padding + 2 * (squareSize + spacing)

    context.setLineWidth(cgSize * 0.012)
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

    return context.makeImage()
}

// Run the generator
generateAppIcons()
print("✅ All app icons generated successfully!")
