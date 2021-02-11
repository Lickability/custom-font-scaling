//
//  DetailViewController.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/1/21.
//

import UIKit
import WebKit

final class DetailViewController: UITableViewController {
    
    private enum Section: Int {
        case systemSwitch = 0
        case slider = 1
        case webview = 2
    }
    
    private let preferences = Preferences()
    private let systemSizeSwitch = UISwitch()
    private let webView = WKWebView()
    
    private lazy var systemSwitchCell: UITableViewCell = {
        systemSizeSwitch.isOn = !preferences.shouldUseUserSelectedContentSizeCategory
        systemSizeSwitch.addTarget(self, action: #selector(systemSizeSwitchTapped(sender:)), for: .touchUpInside)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") else {
            return UITableViewCell()
        }
        
        if let customFont = UIFont(name: "Roboto-Italic", size: 17) {
            cell.textLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
        }
        
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = "System Size"
        cell.contentView.addSubview(systemSizeSwitch)
        return cell
    }()
    
    private lazy var webViewCell: UITableViewCell = {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "webViewCell") else {
            return UITableViewCell()
        }
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.frame = cell.contentView.bounds
        cell.contentView.addSubview(webView)
        return cell
    }()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(forClass: SliderCell.self, reuseIdentifier: SliderCell.defaultNibName)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "webViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        reloadWebView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // If the content category size has changed we need to reload the html.
        reloadWebView()
    }
    
    // MARK: - DetailViewController
    
    func reloadWebView() {
        
        // Setting a placeholder font since the font is loaded through CSS. The font now relies on the system to scale our custom font after calling `scaledFont`.
        let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: .preferredFont(forTextStyle: .body), compatibleWith: traitCollection)
        
        guard let localHTMLURL = Bundle.main.url(forResource: "example", withExtension: "html"),
              let htmlString = try? String(contentsOf: localHTMLURL) else {
            return
        }
        
        // A quick way to style html without modifying the css stylesheet.
        loadHTML(withFont: scaledFont, htmlString: htmlString)
    }
    
    private func loadHTML(withFont font: UIFont, htmlString: String) {
        
        let fontSetting = "<span style=\"font-size: \(font.pointSize)\"</span>"
        webView.loadHTMLString(fontSetting + htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    @objc func systemSizeSwitchTapped(sender: UISwitch) {
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
        if indexPath.section == Section.webview.rawValue {
            return 500
        }
        
        return UITableView.automaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == Section.systemSwitch.rawValue {
            return systemSwitchCell
        } else if indexPath.section == Section.slider.rawValue {
            return sliderCell(indexPath: indexPath)
        } else if indexPath.section == Section.webview.rawValue {
            return webViewCell
        }
        
        return UITableViewCell()
    }
    
    private func sliderCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SliderCell.defaultNibName, for: indexPath) as? SliderCell else {
            return UITableViewCell()
        }
        let isEnabled = preferences.shouldUseUserSelectedContentSizeCategory == true
        cell.viewModel = SliderCell.ViewModel(numberOfSteps: 5, minValue: 1, maxValue: 5, lineHeight: 2, markHeight: 8, isEnabled: isEnabled, configureSlider: { [weak self] slider in
            slider.value = self?.preferences.userSelectedContentSizeCategory?.sliderValue ?? 1.0
        })
        
        cell.sliderValueChangedHandler = { [weak self] newValue in
            self?.preferences.userSelectedContentSizeCategory = UIContentSizeCategory.category(forSliderValue: newValue)
            
            NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
        }
        return cell
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
