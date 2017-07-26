//
//  HorizontalFlowLayout.swift
//  TabbedCollectionView
//
//  Created by Guilherme Moura on 12/6/15.
//  Copyright © 2015 Reefactor, Inc. All rights reserved.
//

import UIKit

class HorizontalFlowLayout: UICollectionViewLayout {
    var itemSize = CGSize.zero {
        didSet {
            invalidateLayout()
        }
    }
    fileprivate var cellCount = 0
    fileprivate var boundsSize = CGSize.zero
    
    override func prepare() {
        cellCount = self.collectionView!.numberOfItems(inSection: 0)
        boundsSize = self.collectionView!.bounds.size
    }
    
    override var collectionViewContentSize : CGSize {
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0 ..< cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = self.computeLayoutAttributesForCellAtIndexPath(indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.computeLayoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !newBounds.size.equalTo(self.collectionView!.bounds.size)
    }
    
    func computeLayoutAttributesForCellAtIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let row = indexPath.row
        let bounds = self.collectionView!.bounds
        
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        
        let columnPosition = row % horizontalItemsCount
        let rowPosition = (row/horizontalItemsCount)%verticalItemsCount
        let itemPage = Int(floor(Double(row)/Double(itemsPerPage)))
        
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        var frame = CGRect.zero
        frame.origin.x = CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * itemSize.width
        frame.origin.y = CGFloat(rowPosition) * itemSize.height
        frame.size = itemSize
        attr.frame = frame
        
        return attr
    }
}
