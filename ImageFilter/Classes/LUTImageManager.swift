//
//  LUTImageManager.swift
//  ImageFilter
//
//  Created by 写BUG on 2020/8/7.
//  Copyright © 2020 改BUG. All rights reserved.
//

import UIKit

class LUTImageItem {
    let name: String
    let image: UIImage
    var isEffect: Bool
    
    init?(dictionary: [String: Any]) {
        guard
            let imagePath = dictionary["image_path"] as? String,
            !imagePath.isEmpty,
            let image = UIImage(contentsOfFile: imagePath) else {
                return nil
        }
        self.image = image
        isEffect = true
        name = dictionary["name"] as? String ?? ""
    }
    
    init(name: String, image: UIImage, isEffect: Bool = true) {
        self.name = name
        self.image = image
        self.isEffect = isEffect
    }
}

class LUTImageManager: NSObject {
    
    static let shared = LUTImageManager()
    
    private(set) var items: [LUTImageItem] = []
    private var hasAddItem = false
    
    private static let directory: String = {
        guard let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return NSTemporaryDirectory()
        }
        return path
    }()
    
    private override init() {
        super.init()
        if let img = UIImage(named: "lut_add") {
            let i = LUTImageItem(name: "添加", image: img, isEffect: false)
            items.append(i)
            hasAddItem = true
        }
        let d = LUTImageManager.directory
        if let savedItems = UserDefaults.standard.value(forKey: "lut_caches") as? [[String: Any]] {
            for i in savedItems {
                guard let fn = i["file_name"] as? String else {
                    continue
                }
                let filePath = (d as NSString).appendingPathComponent(fn)
                guard let img = UIImage(contentsOfFile: filePath) else {
                    continue
                }
                let name = (i["name"] as? String) ?? ""
                let item = LUTImageItem(name: name, image: img)
                items.append(item)
            }
        }
        if let img = UIImage(named: "lut_filter_1") {
            let i = LUTImageItem(name: "测试1", image: img, isEffect: true)
            items.append(i)
        }
    }
    
    func insertLUTImage(_ image: UIImage, name: String) -> LUTImageItem? {
        guard let imageData = image.pngData() else {
            return nil
        }
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "\(formatter.string(from: now)).png"
        let filePath = (LUTImageManager.directory as NSString).appendingPathComponent(fileName)
        (imageData as NSData).write(toFile: filePath, atomically: true)
        let index = hasAddItem ? 1 : 0
        let i = LUTImageItem(name: name, image: image, isEffect: true)
        items.insert(i, at: index)
        
        var cacheItems = [[String: Any]]()
        if let savedItems = UserDefaults.standard.value(forKey: "lut_caches") as? [[String: Any]] {
            cacheItems.append(contentsOf: savedItems)
        }
        cacheItems.append(["name": name, "file_name": fileName])
        UserDefaults.standard.setValue(cacheItems, forKey: "lut_caches")
        UserDefaults.standard.synchronize()
        return i
    }

}
