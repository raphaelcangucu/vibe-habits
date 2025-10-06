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

    // Calculate dimensions for 3x3 grid - larger for better visibility
    // Grid should occupy about 60% of the icon
    let gridSpacing: CGFloat = cgSize * 0.02  // 2% of icon size for spacing
    let totalSpacingWidth = gridSpacing * 2   // 2 gaps between 3 squares
    let squareSize = (cgSize * 0.6 - totalSpacingWidth) / 3.0

    // Calculate total grid size including spacing
    let totalGridWidth = (squareSize * 3) + (gridSpacing * 2)
    let totalGridHeight = (squareSize * 3) + (gridSpacing * 2)

    // Center the grid
    let startX = (cgSize - totalGridWidth) / 2
    let startY = (cgSize - totalGridHeight) / 2

    // Draw 3x3 grid of rounded squares (matching splash screen exactly)
    for row in 0..<3 {
        for col in 0..<3 {
            let x = startX + CGFloat(col) * (squareSize + gridSpacing)
            let y = startY + CGFloat(row) * (squareSize + gridSpacing)

            // White squares with full opacity (matching splash screen)
            context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))

            let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
            let cornerRadius = squareSize * 0.15  // Proportional corner radius

            let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
            context.addPath(path)
            context.fillPath()
        }
    }

    // Add checkmark on top-right square (row 0, col 2)
    // Note: In CGContext, y=0 is at the bottom, so row 0 is actually the bottom row
    // For "top-right" visually, we need row 2, col 2
    let checkRow = 2  // Top row (since y increases upward in CGContext)
    let checkCol = 2  // Right column
    let checkSquareX = startX + CGFloat(checkCol) * (squareSize + gridSpacing)
    let checkSquareY = startY + CGFloat(checkRow) * (squareSize + gridSpacing)

    context.setLineWidth(squareSize * 0.12)
    context.setStrokeColor(CGColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0))
    context.setLineCap(.round)
    context.setLineJoin(.round)

    // Checkmark path - nicely proportioned
    let checkStartX = checkSquareX + squareSize * 0.28
    let checkStartY = checkSquareY + squareSize * 0.50
    let checkMidX = checkSquareX + squareSize * 0.45
    let checkMidY = checkSquareY + squareSize * 0.68
    let checkEndX = checkSquareX + squareSize * 0.72
    let checkEndY = checkSquareY + squareSize * 0.32

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
