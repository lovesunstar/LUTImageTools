//
//  LUTImageFilter.swift
//  ImageFilter
//
//  Created by 写BUG on 2020/8/7.
//  Copyright © 2020 改BUG. All rights reserved.
//

import UIKit
import CoreImage


class LUTImageFilter: NSObject {
    
    static let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let ciFilter: CIFilter
    
    let context: CIContext

    init(filter: CIFilter) {
        self.ciFilter = filter
        context = CIContext(options: [CIContextOption.workingColorSpace: LUTImageFilter.colorSpace])
        super.init()
    }
    
    public static func makeFilter(lut image: UIImage, dimension: Int = 64) -> LUTImageFilter? {
        guard dimension >= 2 else {
            return nil
        }
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        func makeBitmap(_ image: CGImage, colorSpace: CGColorSpace) -> UnsafeMutablePointer<UInt8>? {

            let width = image.width
            let height = image.height

            let bitsPerComponent = 8
            let bytesPerRow = width * 4

            let bitmapSize = bytesPerRow * height

            guard let data = malloc(bitmapSize) else {
                return nil
            }

            guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue, releaseCallback: nil, releaseInfo: nil) else {
                return nil
            }

            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return data.bindMemory(to: UInt8.self, capacity: bitmapSize)
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let rowCount = height / dimension
        let columnCount = width / dimension
        
        guard width == height, width % dimension == 0, height % dimension == 0, rowCount * columnCount == dimension else {
            return nil
        }
        guard let bitmap = makeBitmap(cgImage, colorSpace: colorSpace) else {
            return nil
        }
        
        let bufferSize = dimension * dimension * dimension * MemoryLayout<Float>.size * 4
        let buffer = unsafeBitCast(malloc(bufferSize), to:UnsafeMutablePointer<Float>.self)
        
        var bitmapOffset = 0
        var z : Int = 0
        for _ in 0..<rowCount {
            for y in 0..<dimension {
                let tmp = z
                for _ in 0..<columnCount {
                    for x in 0..<dimension {
                        let alpha = Float(bitmap[Int(bitmapOffset)]) / 255.0
                        let red = Float(bitmap[Int(bitmapOffset + 1)]) / 255.0
                        let green = Float(bitmap[Int(bitmapOffset + 2)]) / 255.0
                        let blue = Float(bitmap[Int(bitmapOffset + 3)]) / 255.0

                        let dataOffset = Int(z * dimension * dimension + y * dimension + x) * 4
                        buffer[dataOffset] = red
                        buffer[dataOffset + 1] = green
                        buffer[dataOffset + 2] = blue
                        buffer[dataOffset + 3] = alpha
                        
                        bitmapOffset += 4
                    }
                    z += 1
                }
                z = tmp
            }
            z += columnCount
        }
        let colorCubeData = NSData(bytesNoCopy: buffer, length: bufferSize, freeWhenDone: true)
        free(bitmap)
        guard let filter = CIFilter(name: "CIColorCube") else {
            return nil
        }
        filter.setValue(colorCubeData, forKey: "inputCubeData")
        filter.setValue(NSNumber(integerLiteral: dimension), forKey: "inputCubeDimension")
        return LUTImageFilter(filter: filter)
    }
    
    func processImage(_ source: UIImage?) -> UIImage? {
        guard let source = source, let sourceCGImage = source.cgImage else {
            return nil
        }
        let image = CIImage(cgImage: sourceCGImage)
        ciFilter.setValue(image, forKey: kCIInputImageKey)
        guard let output = ciFilter.outputImage, let targetCGImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: targetCGImage, scale: source.scale, orientation: source.imageOrientation)
    }

}
