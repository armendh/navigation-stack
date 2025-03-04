//
//  CollectionStackViewController.swift

import UIKit

// MARK: CollectionStackViewController

protocol CollectionStackViewControllerDelegate: AnyObject {
    func controllerDidSelected(index: Int)
}

class CollectionStackViewController: UICollectionViewController {
    fileprivate var screens: [UIImage]
    fileprivate let overlay: Float
    
    weak var delegate: CollectionStackViewControllerDelegate?
    
    init(images: [UIImage],
         delegate: CollectionStackViewControllerDelegate?,
         overlay: Float,
         scaleRatio: Float,
         scaleValue: Float,
         bgColor: UIColor = UIColor.clear,
         bgView: UIView? = nil,
         decelerationRate: CGFloat) {
        
        screens = images
        self.delegate = delegate
        self.overlay = overlay
        
        let layout = CollectionViewStackFlowLayout(itemsCount: images.count, overlay: overlay, scaleRatio: scaleRatio, scale: scaleValue)
        super.init(collectionViewLayout: layout)
        
        if let collectionView = self.collectionView {
            collectionView.backgroundColor = bgColor
            collectionView.backgroundView = bgView
            collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: decelerationRate)
            collectionView.isScrollEnabled = false
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureCollectionView()
        scrolltoIndex(screens.count - 1, animated: false, position: .left) // move to end
    }
    
    override func viewDidAppear(_: Bool) {
        
        guard let collectionViewLayout = self.collectionViewLayout as? CollectionViewStackFlowLayout else {
            fatalError("wrong collection layout")
        }
        
        collectionViewLayout.openAnimating = false
        scrolltoIndex(0, animated: true, position: .left) // open animation
    }
}

// MARK: configure

extension CollectionStackViewController {
    
    fileprivate func configureCollectionView() {
        guard let collectionViewLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("wrong collection layout")
        }
        
        collectionViewLayout.scrollDirection = .horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(CollectionViewStackCell.self, forCellWithReuseIdentifier: String(describing: CollectionViewStackCell.self))
    }
}

// MARK: CollectionViewDataSource

extension CollectionStackViewController {
    
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return screens.count
    }
    
    override func collectionView(_: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? CollectionViewStackCell {
            cell.imageView?.image = screens[(indexPath as NSIndexPath).row]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewStackCell.self),
                                                      for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentCell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        // move cells
        for cell in self.collectionView!.visibleCells where cell != currentCell {
            if let otherIndexPath = collectionView.indexPath(for: cell), otherIndexPath.row > indexPath.row {
                cell.alpha = 0
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve) {
                    cell.alpha = 0
                }
            }
        }
        
        // move to center current cell
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: { () -> Void in
            let offset = self.collectionView.contentOffset.x - (self.view.bounds.size.width - self.collectionView.bounds.size.width * CGFloat(self.overlay)) * CGFloat((indexPath as NSIndexPath).row)
            currentCell.center = CGPoint(x: (currentCell.center.x + offset), y: currentCell.center.y)
        }) { finished in
            if finished {
                self.delegate?.controllerDidSelected(index: (indexPath as NSIndexPath).row)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CollectionStackViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return view.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: NSInteger) -> CGFloat {
        return -collectionView.bounds.size.width * CGFloat(overlay)
    }
}

// MARK: Additional helpers

extension CollectionStackViewController {
    
    fileprivate func scrolltoIndex(_ index: Int, animated: Bool, position: UICollectionView.ScrollPosition) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: position, animated: animated)
    }
}
