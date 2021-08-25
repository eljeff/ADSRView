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
    private var attackCurveSlider: UISlider!
    private var decaySlider: UISlider!
    private var decayCurveSlider: UISlider!
    private var sustainSlider: UISlider!
    private var releaseSlider: UISlider!
    private var releaseCurveSlider: UISlider!
    private var allCurvesSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        addADSRView(frame: view.frame)
        addSliderView(frame: view.frame, yOffset: adsrView.frame.height)
        view.backgroundColor = .black
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
        adsrView.setAllColors(color: .clear)
        adsrView.curveColor = .green
        adsrView.setAllCurves(curveAmount: 1)
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
        attackCurveSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        decayCurveSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        releaseCurveSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))
        allCurvesSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderWidth, height: sliderHeight))

        attackSlider.value = adsrView.attackAmount
        decaySlider.value = adsrView.decayAmount
        sustainSlider.value = adsrView.sustainLevel
        releaseSlider.value = adsrView.releaseAmount
        attackCurveSlider.value = adsrView.attackCurveAmount
        decayCurveSlider.value = adsrView.decayCurveAmount
        releaseCurveSlider.value = adsrView.releaseCurveAmount
        allCurvesSlider.value = 1.0
        attackSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        decaySlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        sustainSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        releaseSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        attackCurveSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        decayCurveSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        releaseCurveSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        allCurvesSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        sliderView.addSubview(attackSlider)
        sliderView.addSubview(decaySlider)
        sliderView.addSubview(sustainSlider)
        sliderView.addSubview(releaseSlider)
        sliderView.addSubview(attackCurveSlider)
        sliderView.addSubview(decayCurveSlider)
        sliderView.addSubview(releaseCurveSlider)
        sliderView.addSubview(allCurvesSlider)
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
        if sender == attackCurveSlider {
            adsrView.attackCurveAmount = sender.value
        }
        if sender == decayCurveSlider {
            adsrView.decayCurveAmount = sender.value
        }
        if sender == releaseCurveSlider {
            adsrView.releaseCurveAmount = sender.value
        }
        if sender == allCurvesSlider {
            adsrView.setAllCurves(curveAmount: sender.value)
            attackCurveSlider.value = sender.value
            decayCurveSlider.value = sender.value
            releaseCurveSlider.value = sender.value
        }
    }

    private func setupSliders(frame: CGRect) {
        attackSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                         xStep: 0, yStep: 0, xSqueezing: 0.9)
        attackCurveSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                              xStep: 0, yStep: 1, xSqueezing: 0.9)
        decaySlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                        xStep: 0, yStep: 2, xSqueezing: 0.9)
        decayCurveSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                             xStep: 0, yStep: 3, xSqueezing: 0.9)
        sustainSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                          xStep: 1, yStep: 0, xSqueezing: 0.9)
        releaseSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                          xStep: 1, yStep: 1, xSqueezing: 0.9)
        releaseCurveSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                               xStep: 1, yStep: 2, xSqueezing: 0.9)
        allCurvesSlider.constrainByDivision(source: sliderView, xDivisions: 2, yDivisions: 4,
                                               xStep: 1, yStep: 3, xSqueezing: 0.9)
    }

    override func viewWillLayoutSubviews() {
        let adsrHeight = view.frame.height * 0.5
        adsrView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: adsrHeight)
        sliderView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 1.0 - adsrHeight)
        setupSliders(frame: sliderView.bounds)
        adsrView.setNeedsDisplay()
    }
}

public extension UIView {

    // source: the container view to spread items out in
    // x/yDivisions = how may equal-sized chunks to divide into
    // x/yStep = how many divsions - to offset (0 is first)
    // x/ySqueezing = percent of actual division size to use (adds padding)
    func constrainByDivision(source: UIView, xDivisions: CGFloat, yDivisions: CGFloat,
                             xStep: CGFloat, yStep: CGFloat,
                             xSqueezing: CGFloat = 1.0, ySqueezing: CGFloat = 1.0) {
        let xDivisor = 1 / xDivisions
        let yDivisor = 1 / yDivisions
        let totalCenter: CGFloat = 2    //how much center multipliers to work w (always 2 - left / right of center)
        let divisionWidth = totalCenter / xDivisions
        let divisionHeight = totalCenter / yDivisions
        let centerXOffset = xStep * divisionWidth
        let xOffset = centerXOffset + xDivisor
        let centerYOffset = yStep * divisionHeight
        let yOffset = centerYOffset + yDivisor
        let widthMultiplier = xDivisor * xSqueezing
        let heightMultiplier  = yDivisor * ySqueezing
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

