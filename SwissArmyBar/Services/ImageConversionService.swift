import AppKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageConversionError: Error {
    case unsupported
    case writeFailed
}

enum ImageConversionService {
    static func convert(inputURL: URL, outputType: String) throws -> URL {
        guard let image = NSImage(contentsOf: inputURL) else {
            throw ImageConversionError.unsupported
        }
        let outputExtension = outputType.lowercased()
        let outputName = inputURL.deletingPathExtension().lastPathComponent + "-converted.\(outputExtension)"
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(outputName)

        let success: Bool
        switch outputType.uppercased() {
        case "JPG", "JPEG":
            success = write(image: image, to: output, type: .jpeg, compression: 0.9)
        case "PNG":
            success = write(image: image, to: output, type: .png, compression: 1.0)
        case "HEIC":
            success = writeHEIC(image: image, to: output)
        default:
            throw ImageConversionError.unsupported
        }

        guard success else {
            throw ImageConversionError.writeFailed
        }
        return output
    }

    private static func write(image: NSImage, to url: URL, type: NSBitmapImageRep.FileType, compression: CGFloat) -> Bool {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let data = rep.representation(using: type, properties: [.compressionFactor: compression]) else {
            return false
        }
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    private static func writeHEIC(image: NSImage, to url: URL) -> Bool {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return false
        }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.heic.identifier as CFString, 1, nil) else {
            return false
        }
        let options: CFDictionary = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        return CGImageDestinationFinalize(destination)
    }
}
