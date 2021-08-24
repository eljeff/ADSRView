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
    private var slider1: UISlider!
    private var slider2: UISlider!
    private var slider3: UISlider!
    private var slider4: UISlider!

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
                self?.slider1.setValue(attack, animated: true)
                self?.slider2.setValue(decay, animated: true)
                self?.slider3.setValue(sustain, animated: true)
                self?.slider4.setValue(release, animated: true)
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
        slider1 = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        slider2 = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        slider3 = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        slider4 = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))

        slider1.value = Float(adsrView.attackAmount)
        slider2.value = Float(adsrView.decayAmount)
        slider3.value = Float(adsrView.sustainLevel)
        slider4.value = Float(adsrView.releaseAmount)
        slider1.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        slider2.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        slider3.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        slider4.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        sliderView.addSubview(slider1)
        sliderView.addSubview(slider2)
        sliderView.addSubview(slider3)
        sliderView.addSubview(slider4)
        view.addSubview(sliderView)
    }

    @objc private func sliderValueDidChange(_ sender: UISlider) {
        if sender == slider1 {
            adsrView.attackAmount = sender.value
        }
        if sender == slider2 {
            adsrView.decayAmount = sender.value
        }
        if sender == slider3 {
            adsrView.sustainLevel = sender.value
        }
        if sender == slider4 {
            adsrView.releaseAmount = sender.value
        }
    }

    private func setupSliders(frame: CGRect) {
        slider1.constrainByDivision(source: sliderView, divisions: 2, xStep: 0, yStep: 0,
                                  xSqueezing: 0.9)
        slider2.constrainByDivision(source: sliderView, divisions: 2, xStep: 0, yStep: 1,
                                  xSqueezing: 0.9)
        slider3.constrainByDivision(source: sliderView, divisions: 2, xStep: 1, yStep: 0,
                                  xSqueezing: 0.9)
        slider4.constrainByDivision(source: sliderView, divisions: 2, xStep: 1, yStep: 1,
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

