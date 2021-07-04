//
//  NavigationStack.swift

import UIKit

/// UINavigationcontroller with animation show lists of UIViewControllers
open class NavigationStack: UINavigationController {

    var overlay: Float = 0.8
    var scaleRatio: Float = 14.0
    var scaleValue: Float = 0.99

    /// A floating-point value that determines the rate of deceleration after the user lifts their finger.
    @IBInspectable open var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /// The color to use for the background of the lists of UIViewcontrollers.
    @IBInspectable open var bgColor: UIColor = .black

    /// The background UIView of the lists of UIViewcontrollers.
    open var bgView: UIView?
    fileprivate var screens = [UIImage]()

    /// The delegate of the navigation controller object. Use this instead delegate.
    open weak var stackDelegate: UINavigationControllerDelegate?

    /**
     The initialized navigation controller object or nil if there was a problem initializing the object.

     - parameter aDecoder: aDecoder

     - returns: The initialized navigation controller object or nil if there was a problem initializing the object.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        delegate = self
    }

    /**
     Initializes and returns a newly created navigation controller.

     - parameter rootViewController: The view controller that resides at the bottom of the navigation stack.

     - returns: The initialized navigation controller object or nil if there was a problem initializing the object.
     */
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        delegate = self
    }

    /**
     Necessary to prevent a crash
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}

// MARK: pulbic methods

extension NavigationStack {

    /**
     Show list of ViewControllers.
     */
    public func showControllers() {
        if screens.count == 0 {
            return
        }

        var allScreens = screens
        allScreens.append(view.takeScreenshot())
        let collectioView = CollectionStackViewController(images: allScreens,
                                                          delegate: self,
                                                          overlay: overlay,
                                                          scaleRatio: scaleRatio,
                                                          scaleValue: scaleValue,
                                                          bgColor: bgColor,
                                                          bgView: bgView,
                                                          decelerationRate: decelerationRate)
        collectioView.modalPresentationStyle = .overFullScreen
        collectioView.modalTransitionStyle = .crossDissolve
        present(collectioView, animated: true, completion: nil)
    }
}

// MARK: UINavigationControllerDelegate

extension NavigationStack: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {

        stackDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)

        if navigationController.viewControllers.count > screens.count + 1 {
            screens.append(view.takeScreenshot())
        } else
        if navigationController.viewControllers.count == screens.count && screens.count > 0 {
            screens.removeLast()
        }
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        stackDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return stackDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return stackDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}

extension NavigationStack: CollectionStackViewControllerDelegate {
    func controllerDidSelected(index: Int) {

        let newViewControllers = Array(viewControllers[0 ... index])
        setViewControllers(newViewControllers, animated: false)
        screens.removeSubrange(index ..< screens.count)
    }
}

// MARK: UIView

extension UIView {

    func takeScreenshot() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
