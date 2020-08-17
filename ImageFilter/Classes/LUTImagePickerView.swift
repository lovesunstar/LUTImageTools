//
//  LUTImagePickerView.swift
//  ImageFilter
//
//  Created by 写BUG on 2020/8/7.
//  Copyright © 2020 改BUG. All rights reserved.
//

import UIKit

class LUTImagePickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    enum UI {
        static let height: CGFloat = 100
    }
    
    var didChangeItem:((LUTImageItem) -> Void)?
    var didAddItem:(()->Void)?
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundView = nil
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        return collectionView
    }()
    
    var items: [LUTImageItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedItem: LUTImageItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.frame = CGRect(x: 8, y: 0, width: self.bounds.width - 16, height: 70)
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Identifier")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
    
    // - MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Identifier", for: indexPath) as! Cell
        let item = items[indexPath.row]
        cell.item = item
        if let sv = selectedItem {
            cell.isLUTSelected = (item === sv)
        } else {
            cell.isLUTSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if item.isEffect {
            selectedItem = item
            didChangeItem?(item)
        } else {
            didAddItem?()
        }
        collectionView.reloadData()
    }
    
    fileprivate class Cell: UICollectionViewCell {
        
        fileprivate let nameLabel = UILabel(frame: .zero)
        fileprivate let iconView = UIImageView(frame: .zero)
                
        fileprivate var item: LUTImageItem? {
            didSet {
                guard let item = item else { return }
                
                iconView.image = item.image
                nameLabel.text = item.name
                
                let borderColor = isLUTSelected ? UIColor(rgb: 0x39b9f8) : UIColor.clear
                let textColor = isLUTSelected ? UIColor(rgb: 0x39b9f8) : UIColor.darkGray
                iconView.layer.borderColor = borderColor.cgColor
                nameLabel.textColor = textColor
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            iconView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            iconView.contentMode = .scaleAspectFill
            iconView.layer.cornerRadius = 7
            iconView.layer.borderWidth = 2
            iconView.layer.borderColor = UIColor.lightGray.cgColor
            iconView.clipsToBounds = true
            self.contentView.addSubview(iconView)
            
            nameLabel.textAlignment = .center
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            nameLabel.textColor = UIColor.red
            nameLabel.adjustsFontSizeToFitWidth = true
            self.contentView.addSubview(nameLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            iconView.frame = CGRect(x: (self.bounds.width - 80) * 0.5, y: 0, width: 80, height: 80)
            nameLabel.frame = CGRect(x: 0, y: 80, width: self.bounds.width, height: 20)
        }
        
        var isLUTSelected: Bool = false {
            didSet {
                let borderColor = isLUTSelected ? UIColor(rgb: 0x39b9f8) : UIColor.clear
                let textColor = isLUTSelected ? UIColor(rgb: 0x39b9f8) : UIColor.darkGray
                iconView.layer.borderColor = borderColor.cgColor
                nameLabel.textColor = textColor
            }
        }
    }


}
