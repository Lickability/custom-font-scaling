//
//  SliderCell.swift
//  DynamicTypeDemo
//
//  Created by Daisy Ramos on 2/1/21.
//

import UIKit

class SliderCell: UITableViewCell {
    
    /// The view model containing information necessary for configuring the display of the slider cell.
    struct ViewModel {
        
        /// The number of steps that divide the slider.
        let numberOfSteps: Int
        
        /// The minimum value that the slider can represent.
        let minValue: Float
        
        /// The maximum value that the slider can represent.
        let maxValue: Float
        
        /// The height of the line view on the track view.
        let lineHeight: CGFloat
        
        /// The height of a mark on the track view.
        let markHeight: CGFloat
        
        /// Whether the slider is enabled.
        let isEnabled: Bool
        
        /// Closure for configuring the `UISlider`.
        let configureSlider: (UISlider) -> Void
    }
    
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var trackView: TrackView!
    
    private var lastSliderValue: Float = 0.0
    
    /// Signature of a closure called when the value of the slider changes.
    typealias SliderValueChangedHandler = ((Float) -> Void)
    
    /// Closure called when the value of the slider changes.
    var sliderValueChangedHandler: SliderValueChangedHandler?
    
    /// The view model containing information necessary for configuring the display. Setting this property updates the display of the view.
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            slider.maximumValue = viewModel.maxValue
            slider.minimumValue = viewModel.minValue
            
            let numberOfSteps = viewModel.numberOfSteps
            let lineHeight = viewModel.lineHeight
            let markHeight = viewModel.markHeight 
            
            slider.isEnabled = viewModel.isEnabled
            trackView.viewModel = TrackView.ViewModel(lineColor: .white, lineHeight: lineHeight, markColor: .red, markHeight: markHeight, numberOfMarks: numberOfSteps)
            
            viewModel.configureSlider(slider)
            lastSliderValue = slider.value
        }
    }
    
    private var stepInterval: Float {
        guard let numberOfSteps = viewModel?.numberOfSteps, numberOfSteps > 0 else { return 0.0 }
        
        return (viewModel?.maxValue ?? 0) / Float(numberOfSteps)
    }
    
    // MARK: - NSObject
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        slider.setMinimumTrackImage(UIImage(), for: .normal)
        slider.setMaximumTrackImage(UIImage(), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged(sender: UISlider) {
        sender.value = round(sender.value / stepInterval) * stepInterval
        
        if lastSliderValue != sender.value {
            sliderValueChangedHandler?(sender.value)
            lastSliderValue = sender.value
        }
    }
}
