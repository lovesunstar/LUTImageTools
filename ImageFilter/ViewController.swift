//
//  ViewController.swift
//  ImageFilter
//
//  Created by 写BUG on 2020/8/7.
//  Copyright © 2020 改BUG. All rights reserved.
//

import UIKit

private let defaultImage = UIImage(named: "IMG_4777.jpg")

class ViewController: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    private lazy var lutView = LUTImagePickerView()
    
    private var sourceImage: UIImage?  {
        didSet {
            if let cgImage = sourceImage?.cgImage {
                let imageWidth = CGFloat(cgImage.width)
                let imageHeight = CGFloat(cgImage.height)
                if imageWidth > imageHeight {
                    imageView.contentMode = .scaleAspectFit
                } else {
                    imageView.contentMode = .scaleAspectFill
                }
            } else {
                imageView.contentMode = .scaleAspectFit
            }
            let start = Date()
            processedImage = filter?.processImage(sourceImage)
            let latency = Date().timeIntervalSince(start)
            print("====>", Int(latency * 1000000))
            imageView.image = processedImage
        }
    }
    
    private var filter: LUTImageFilter? {
        didSet {
            let start = Date()
            processedImage = filter?.processImage(sourceImage)
            let latency = Date().timeIntervalSince(start)
            print("====>", Int(latency * 1000000))
            imageView.image = processedImage
        }
    }
    
    private var processedImage: UIImage?
    
    private weak var imagePicker: UIImagePickerController?
    private weak var lutPicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultItem = LUTImageManager.shared.items.first(where: {$0.isEffect})
        lutView.selectedItem = defaultItem
        lutView.items = LUTImageManager.shared.items
        self.view.addSubview(lutView)
        
        lutView.didAddItem = { [weak self] in
            guard let `self` = self else {
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
            self.lutPicker = imagePicker
        }
        lutView.didChangeItem = { [weak self] (item) in
            guard let `self` = self else {
                return
            }
            self.filter = LUTImageFilter.makeFilter(lut: item.image)
        }
        
        sourceImage = defaultImage
        if let i = defaultItem {
            filter = LUTImageFilter.makeFilter(lut: i.image)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lutView.frame = CGRect(x: 0, y: self.view.bounds.height - self.view.safeAreaInsets.bottom - LUTImagePickerView.UI.height, width: self.view.bounds.width, height: LUTImagePickerView.UI.height)
    }

    @IBAction func handleChangeImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        self.imagePicker = imagePicker
    }
    
    @IBAction func handleClearImage(_ sender: Any) {
        sourceImage = defaultImage
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            imageView.image = sourceImage
        case _:
            imageView.image = processedImage ?? sourceImage
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UILongPressGestureRecognizer else {
            return true
        }
        let location = gesture.location(in: containerView)
        return !(clearButton.frame.contains(location) || imageButton.frame.contains(location))
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == self.imagePicker {
            if let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) {
                self.sourceImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        } else if picker == self.lutPicker {
            if let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) {
                if let filter = LUTImageFilter.makeFilter(lut: image) {
                    let alertController = UIAlertController(title: "请输入LUT名称", message: nil, preferredStyle: .alert)
                    alertController.addTextField(configurationHandler: nil)
                    let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] (_) in
                        guard let `self` = self else {
                            return
                        }
                        let name = alertController.textFields?.first?.text ?? "未命名"
                        let insertedItem = LUTImageManager.shared.insertLUTImage(image, name: name)
                        self.filter = filter
                        self.lutView.selectedItem = insertedItem
                        self.lutView.items = LUTImageManager.shared.items
                        picker.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(confirmAction)
                    picker.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "LUT图片不合法", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                    picker.present(alertController, animated: true, completion: nil)
                }
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

