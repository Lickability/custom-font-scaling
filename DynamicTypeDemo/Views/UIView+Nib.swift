//
//  UIView+Nib.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/2/21.
//

import UIKit

/// Provides `UIView` with additionality functionality around instantiating views from nibs.
extension UIView {
    
    /// Instantiate the nib for the provided `nibName` string.
    ///
    /// - Parameter nibName: The name of the nib to load.
    /// - Returns: An optional version of the instantiated nib.
    static func instantiateViewFromNib<T: UIView>(_ nibName: String, bundle: Bundle? = nil) -> T? {
        return UINib(nibName: nibName, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? T
    }
    
    private static func defaultNibName() -> String {
        return String(describing: self)
    }
    
    /// Loads a nib file when calling method in `awakeAfter(using:)`. It will replace `self` with the view. Based on [Cocoanuts](http://cocoanuts.mobi/2014/03/26/reusable).
    ///
    /// - Parameters:
    ///   - nibName: The name of the nib to load the view. Nil will use the default class name.
    ///   - bundle: The bundle location of the nib.
    /// - Returns: View loaded from the nib. It's cosntraints will be recreated. Use this as the return value in `awakeAfter(using:)`.
    func viewFromNib(named nibName: String? = nil, bundle: Bundle? = nil) -> UIView? {
        // Return `Self` if the method has already been called so it doesn not happen multiple times.
        guard subviews.isEmpty else {
            return self
        }
        
        let name = nibName ?? type(of: self).defaultNibName()
        
        let nibView: UIView? = UIView.instantiateViewFromNib(name, bundle: bundle)
        guard let view = nibView else {
            return nil
        }
        
        view.frame = frame
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        view.autoresizingMask = autoresizingMask
        view.isUserInteractionEnabled = isUserInteractionEnabled
        view.isHidden = isHidden
        
        let newConstraints: [NSLayoutConstraint] = constraints.map { constraint in
            let firstItem = constraint.firstItem as? UIView == self ? view : constraint.firstItem
            let secondItem = constraint.secondItem as? UIView == self ? view : constraint.secondItem
            
            let newConstraint = NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
            newConstraint.priority = constraint.priority
            return newConstraint
        }
        
        NSLayoutConstraint.activate(newConstraints)
        
        return view
    }
}
