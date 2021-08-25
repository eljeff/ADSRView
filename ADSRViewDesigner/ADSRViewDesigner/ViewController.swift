//
//  ViewController.swift
//  ADSRViewDesigner
//
//  Created by Jeff Cooper on 8/24/21.
//

import UIKit

class ViewController: UIViewController {

    private var adsrView: ADSRView!
    private var sliderView: UIView!
    private var attackSlider: UISlider!
    private var decaySlider: UISlider!
    private var sustainSlider: UISlider!
    private var releaseSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        addADSRView(frame: view.frame)
        addSliderView(frame: view.frame, yOffset: adsrView.frame.height)
    }

    private func addADSRView(frame: CGRect) {
        adsrView = ADSRView()
        view.addSubview(adsrView)
        adsrView.callback = {[weak self] attack, decay, sustain, release in
            DispatchQueue.main.async { [weak self] in
                self?.attackSlider.setValue(attack, animated: true)
                self?.decaySlider.setValue(decay, animated: true)
                self?.sustainSlider.setValue(sustain, animated: true)
                self?.releaseSlider.setValue(release, animated: true)
            }
        }
    }

    private func addSliderView(frame: CGRect, yOffset: CGFloat) {
        let height = frame.height * 0.5
        let width = frame.width
        sliderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        sliderView.backgroundColor = .lightGray
        let sliderWidth = frame.width * 0.4
        let sliderHeight = frame.width * 0.4
        attackSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        decaySlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        sustainSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        releaseSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))

        attackSlider.value = Float(adsrView.attackAmount)
        decaySlider.value = Float(adsrView.decayAmount)
        sustainSlider.value = Float(adsrView.sustainLevel)
        releaseSlider.value = Float(adsrView.releaseAmount)
        attackSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        decaySlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        sustainSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        releaseSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        sliderView.addSubview(attackSlider)
        sliderView.addSubview(decaySlider)
        sliderView.addSubview(sustainSlider)
        sliderView.addSubview(releaseSlider)
        view.addSubview(sliderView)
    }

    @objc private func sliderValueDidChange(_ sender: UISlider) {
        if sender == attackSlider {
            adsrView.attackAmount = sender.value
        }
        if sender == decaySlider {
            adsrView.decayAmount = sender.value
        }
        if sender == sustainSlider {
            adsrView.sustainLevel = sender.value
        }
        if sender == releaseSlider {
            adsrView.releaseAmount = sender.value
        }
    }

    private func setupSliders(frame: CGRect) {
        attackSlider.constrainByDivision(source: sliderView, divisions: 2, xStep: 0, yStep: 0,
                                  xSqueezing: 0.9)
        decaySlider.constrainByDivision(source: sliderView, divisions: 2, xStep: 0, yStep: 1,
                                  xSqueezing: 0.9)
        sustainSlider.constrainByDivision(source: sliderView, divisions: 2, xStep: 1, yStep: 0,
                                  xSqueezing: 0.9)
        releaseSlider.constrainByDivision(source: sliderView, divisions: 2, xStep: 1, yStep: 1,
                                  xSqueezing: 0.9)
    }

    override func viewWillLayoutSubviews() {
        let adsrHeight = view.frame.height * 0.5
        adsrView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: adsrHeight)
        sliderView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 1.0 - adsrHeight)
        setupSliders(frame: sliderView.bounds)
    }
}

public extension UIView {

    // divisions = how may equal-sized chunks to divide into
    // -Step = how many divsions - to offset (0 is first)
    // -Squeezing = percent of actual division size to use (adds padding)
    func constrainByDivision(source: UIView, divisions: CGFloat,
                             xStep: CGFloat, yStep: CGFloat,
                             xSqueezing: CGFloat = 1.0, ySqueezing: CGFloat = 1.0) {
        let divisor = 1 / divisions
        let totalCenter: CGFloat = 2    //how much center multipliers to work w (always 2 - left / right of center)
        let centerWidth = totalCenter / divisions
        let centerXOffset = xStep * centerWidth
        let xOffset = centerXOffset + divisor
        let centerYOffset = yStep * centerWidth
        let yOffset = centerYOffset + divisor
        let widthMultiplier = divisor * xSqueezing
        let heightMultiplier  = divisor * ySqueezing
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX,
                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: source,
                           attribute: NSLayoutConstraint.Attribute.centerX,
                           multiplier: xOffset, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY,
                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: source,
                           attribute: NSLayoutConstraint.Attribute.centerY,
                           multiplier: yOffset, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width,
                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: source,
                           attribute: NSLayoutConstraint.Attribute.width,
                           multiplier: widthMultiplier, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height,
                           relatedBy: NSLayoutConstraint.Relation.equal, toItem: source,
                           attribute: NSLayoutConstraint.Attribute.height,
                           multiplier: heightMultiplier, constant: 0).isActive = true
    }
}

