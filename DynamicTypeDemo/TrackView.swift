//
//  TrackView.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/2/21.
//

import UIKit

/// A view that represents a track that a slider typically runs on, with marks at even intervals.
final class TrackView: UIView {
    
    /// The view model containing information necessary for configuring the display of the track view.
    struct ViewModel {
        
        /// The color of the line.
        let lineColor: UIColor
        
        /// The height of the line.
        let lineHeight: CGFloat
        
        /// The color of marks.
        let markColor: UIColor
        
        /// The height of marks.
        let markHeight: CGFloat
        
        /// The number of marks displayed.
        let numberOfMarks: Int
    }
    
    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var markStackView: UIStackView!
    @IBOutlet private weak var lineViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var markViewHeightConstraint: NSLayoutConstraint!
    
    /// The view model containing information necessary for configuring the display. Setting this property updates the display of the view.
    var viewModel: ViewModel? {
        didSet {
            lineView.backgroundColor = viewModel?.lineColor
            lineViewHeightConstraint.constant = viewModel?.lineHeight ?? 0.0
            markViewHeightConstraint.constant = viewModel?.markHeight ?? 0.0
            
            markStackView.removeAllArrangedSubviews()
            addMarks(numberToAdd: viewModel?.numberOfMarks ?? 0)
        }
    }
    
    // MARK: - NSObject
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return viewFromNib()
    }

    // MARK: - TrackView
    
    private func addMarks(numberToAdd: Int) {
        for _ in 1...numberToAdd {
            let view = markView(forSize: viewModel?.markHeight ?? 0.0)
            
            markStackView.addArrangedSubview(view)
        }
    }
    
    private func markView(forSize size: CGFloat) -> UIView {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        view.backgroundColor = viewModel?.markColor
        view.layer.cornerRadius = size / 2.0
        
        return view
    }
}

private extension UIStackView {
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
