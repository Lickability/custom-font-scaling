//
//  DetailViewController.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/1/21.
//

import UIKit
import WebKit

class DetailViewController: UITableViewController {
    
    let preferences = Preferences()
    
    private lazy var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = false
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        return WKWebView(frame: .zero, configuration: configuration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(forClass: SliderCell.self, reuseIdentifier: SliderCell.defaultNibName)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "webViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func contentSizeDidChange(_ notification: Notification) {
        let contentSizeCategory: UIContentSizeCategory

        if preferences.shouldUseUserSelectedContentSizeCategory, let userSelectedContentSizeCategory = preferences.userSelectedContentSizeCategory {
            contentSizeCategory = userSelectedContentSizeCategory
        } else {
            contentSizeCategory = UITraitCollection.current.preferredContentSizeCategory
        }

        let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
        setOverrideTraitCollection(traitCollection, forChild: self)
        webView.reload()
    }
    
    @objc private func systemSizeSwitchTapped(sender: UISwitch) {
        preferences.shouldUseUserSelectedContentSizeCategory = !sender.isOn
        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 500
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
            let systemSizeSwitch = UISwitch()
            systemSizeSwitch.isOn = !preferences.shouldUseUserSelectedContentSizeCategory
            systemSizeSwitch.addTarget(self, action: #selector(systemSizeSwitchTapped(sender:)), for: .touchUpInside)
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") else {
                return UITableViewCell()
            }
            cell.contentView.addSubview(systemSizeSwitch)
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.text = "System Size"
            return cell
            
        } else if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SliderCell.defaultNibName, for: indexPath) as? SliderCell else {
                return UITableViewCell()
            }
            cell.viewModel = SliderCell.ViewModel(numberOfSteps: 5, minValue: 1, maxValue: 5, lineHeight: 2, markHeight: 8, configureSlider: { [weak self] slider in
                slider.value = self?.preferences.userSelectedContentSizeCategory?.sliderValue ?? 1.0
            })
            
            cell.sliderValueChangedHandler = { [weak self] newValue in
                self?.preferences.userSelectedContentSizeCategory = UIContentSizeCategory.category(forSliderValue: newValue)
                
                NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
                tableView.reloadData()
            }
            return cell
        } else if indexPath.section == 2 {
                
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "webViewCell") else {
                return UITableViewCell()
            }
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.frame = cell.contentView.bounds
            if let url = Bundle.main.url(forResource: "example", withExtension: "html") {
                webView.loadFileURL(url, allowingReadAccessTo: url)
            }
            cell.contentView.addSubview(webView)
            return cell 
        }

        return UITableViewCell()
    }
}

private extension UIContentSizeCategory {
    
    var sliderValue: Float {
        switch self {
        case UIContentSizeCategory.small:
            return 1
        case UIContentSizeCategory.medium:
            return 2
        case UIContentSizeCategory.large:
            return 3
        case UIContentSizeCategory.extraLarge:
            return 4
        case UIContentSizeCategory.extraExtraLarge:
            return 5
        default:
            return 3
        }
    }
    
    static func category(forSliderValue sliderValue: Float) -> UIContentSizeCategory {
        switch sliderValue {
        case 1:
            return .small
        case 2:
            return .medium
        case 3:
            return .large
        case 4:
            return .extraLarge
        case 5:
            return .extraExtraLarge
        default:
            return .medium
        }
    }
}

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

