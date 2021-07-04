//
//  CollectionViewStackFlowLayout.swift

import UIKit

// MARK: CollectionViewStackFlowLayout

class CollectionViewStackFlowLayout: UICollectionViewFlowLayout {

    let itemsCount: Int
    let overlay: Float // from 0 to 1

    let maxScale: Float
    let scaleRatio: Float

    var additionScale = 1.0
    var openAnimating = false

    var dxOffset: Float = 0

    init(itemsCount: Int, overlay: Float, scaleRatio: Float, scale: Float) {
        self.itemsCount = itemsCount
        self.overlay = overlay
        self.scaleRatio = scaleRatio
        maxScale = scale
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionViewStackFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let items = NSArray(array: super.layoutAttributesForElements(in: rect)!, copyItems: true)
        var headerAttributes: UICollectionViewLayoutAttributes?

        items.enumerateObjects({ (object, _, _) -> Void in
            let attributes = object as! UICollectionViewLayoutAttributes

            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                headerAttributes = attributes
            } else {
                self.updateCellAttributes(attributes, headerAttributes: headerAttributes)
            }
        })
        return items as? [UICollectionViewLayoutAttributes]
    }

    func updateCellAttributes(_ attributes: UICollectionViewLayoutAttributes, headerAttributes _: UICollectionViewLayoutAttributes?) {
        // set contentOffset range

        if additionScale > 0 && openAnimating {
            additionScale -= 0.02
            additionScale = additionScale < 0 ? 0 : additionScale
        }
        attributes.zIndex = (attributes.indexPath as NSIndexPath).row
    }

    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
}
