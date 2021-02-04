//
//  UITableView+NibRegistration.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/4/21.
//

import UIKit

extension UITableView {
    
    /// Registers a nib using the provided class name as the nib name under a specific reuse identifier.
    ///
    /// - Parameters:
    ///   - tableViewCellClass: The class of the table view cell represented by the corresponding nib being registered.
    ///   - bundle: The bundle in which the nib is located, or nil for the main bundle. Defaults to `nil`.
    ///   - reuseIdentifier: The reuse identifier to associate with the specified nib file.
    func registerNib(forClass tableViewCellClass: UITableViewCell.Type, in bundle: Bundle? = nil, reuseIdentifier: String) {
        let nibName = tableViewCellClass.defaultNibName
        
        register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: reuseIdentifier)
    }
}

extension NSCoding {
    
    /// The default name for a nib. Matches the name of the class, without any module name spacing.
    static var defaultNibName: String {
        return String(describing: self)
    }
}

