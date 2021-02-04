//
//  FontScalingNavigationController.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/1/21.
//

import UIKit

class FontScalingNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForOverrideNotifications()
        overrideChildrenContentSizeCategories()
    }
    
    // Overrides the font cateogry to be used.
    override func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        
        overrideContentSizeCategory(childController)
    }
}

fileprivate extension UIViewController {
    func registerForOverrideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(overrideChildrenContentSizeCategories), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    func overrideContentSizeCategory(_ child: UIViewController) {
        
        // Local storage
        let preferences = Preferences()

        let contentSizeCategory: UIContentSizeCategory
        
        // Whether to use the user-selected content size category or the system one.
        if preferences.shouldUseUserSelectedContentSizeCategory, let userSelectedContentSizeCategory = preferences.userSelectedContentSizeCategory {
            contentSizeCategory = userSelectedContentSizeCategory
        } else {
            contentSizeCategory = UITraitCollection.current.preferredContentSizeCategory
        }
        
        // The setting to scale the font.
        let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
        setOverrideTraitCollection(traitCollection, forChild: child)
    }
    
    // Iterates through the child view controllers.
    @objc func overrideChildrenContentSizeCategories() {
        children.forEach { child in
            overrideContentSizeCategory(child)
        }
    }
}


