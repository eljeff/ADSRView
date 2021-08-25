//
//  ADSRView.swift
//  ADSRViewDesigner
//
//  Created by Jeff Cooper on 8/24/21.
//

import UIKit

/// A click and draggable view of an ADSR Envelope (Atttack, Decay, Sustain, Release)
/// All values are normalised 0->1, so scale them how you would like in your callback

@IBDesignable public class ADSRView: UIView {
    /// Type of function to call when values of the ADSR have changed
    public typealias ADSRCallback = (Float, Float, Float, Float) -> Void

    /// Attack amount, Default: 0.5
    open var attackAmount: Float = 0.5 { didSet { setNeedsDisplay() } }

    /// Decay amount, Default: 0.5
    open var decayAmount: Float = 0.5 { didSet { setNeedsDisplay() } }

    /// Sustain Level (0-1), Default: 0.5
    open var sustainLevel: Float = 0.5 { didSet { setNeedsDisplay() } }

    /// Release amount, Default: 0.5
    open var releaseAmount: Float = 0.5 { didSet { setNeedsDisplay() } }

    /// How much to slow the  drag - lower is slower, Default: 0.005
    open var dragSlew: Float = 0.005

    /// How much curve to apply to the attack section - 0 = no curve, 1 = full curve, Default: 1.0
    open var attackCurveAmount: Float = 1.0 { didSet { setNeedsDisplay() } }

    /// How much curve to apply to the decay section - 0 = no curve, 1 = full curve, Default: 1.0
    open var decayCurveAmount: Float = 1.0 { didSet { setNeedsDisplay() } }

    /// How much curve to apply to the release section - 0 = no curve, 1 = full curve, Default: 1.0
    open var releaseCurveAmount: Float = 1.0 { didSet { setNeedsDisplay() } }

    /// Use gradient or solid color sections, Default: true
    open var useGradient: Bool = true { didSet { setNeedsDisplay() } }

    /// How much area to leave before attack to allow manipulation if attack == 0
    open var attackPaddingPercent: CGFloat = 0.06

    /// How much area to leave after release
    open var releasePaddingPercent: CGFloat = 0.01

    private var decaySustainTouchAreaPath = UIBezierPath()
    private var attackTouchAreaPath = UIBezierPath()
    private var releaseTouchAreaPath = UIBezierPath()

    /// Function to call when the values of the ADSR changes
    open var callback: ADSRCallback?
    private var currentDragArea = ""

    //// Color Declarations

    /// Color in the attack portion of the UI element
    @IBInspectable open var attackColor: UIColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)

    /// Color in the decay portion of the UI element
    @IBInspectable open var decayColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

    /// Color in the sustain portion of the UI element
    @IBInspectable open var sustainColor: UIColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)

    /// Color in the release portion of the UI element
    @IBInspectable open var releaseColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)

    /// Background color
    @IBInspectable open var bgColor: UIColor = UIColor.clear

    /// Width of the envelope curve
    @IBInspectable open var curveStrokeWidth: CGFloat = 2

    /// Color of the envelope curve
    @IBInspectable open var curveColor: UIColor = .black

    private var lastPoint = CGPoint.zero

    public func setAllCurves(curveAmount: Float) {
        attackCurveAmount = curveAmount
        decayCurveAmount = curveAmount
        releaseCurveAmount = curveAmount
    }

    public func setAllColors(color: UIColor) {
        attackColor = color
        decayColor = color
        sustainColor = color
        releaseColor = color
    }

    // MARK: - Initialization

    /// Initialize the view, usually with a callback
    public init(callback: ADSRCallback? = nil) {
        self.callback = callback
        super.init(frame: CGRect(x: 0, y: 0, width: 440, height: 150))
        backgroundColor = bgColor
    }

    /// Initialization of the view from within interface builder
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Storyboard Rendering

    /// Perform necessary operation to allow the view to be rendered in interface builder
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }

    /// Size of the view
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 440, height: 150)
    }

    /// Requeire a constraint based layout with interface builder
    override public class var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Touch Handling

    /// Handle new touches
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            if decaySustainTouchAreaPath.contains(touchLocation) {
                currentDragArea = "ds"
            }
            if attackTouchAreaPath.contains(touchLocation) {
                currentDragArea = "a"
            }
            if releaseTouchAreaPath.contains(touchLocation) {
                currentDragArea = "r"
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }

    /// Handle moving touches
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)

            if currentDragArea != "" {
                if currentDragArea == "ds" {
                    sustainLevel -= Float(touchLocation.y - lastPoint.y) * dragSlew
                    decayAmount += Float(touchLocation.x - lastPoint.x) * dragSlew
                }
                if currentDragArea == "a" {
                    attackAmount += Float(touchLocation.x - lastPoint.x) * dragSlew
                    attackAmount -= Float(touchLocation.y - lastPoint.y) * dragSlew
                }
                if currentDragArea == "r" {
                    releaseAmount += Float(touchLocation.x - lastPoint.x) * dragSlew
                    releaseAmount -= Float(touchLocation.y - lastPoint.y) * dragSlew
                }
            }
            attackAmount = max(min(attackAmount, 1), 0)
            decayAmount = max(min(decayAmount, 1), 0)
            sustainLevel = max(min(sustainLevel, 1), 0)
            releaseAmount = max(min(releaseAmount, 1), 0)

            if let callback = callback {
                callback(attackAmount,
                         decayAmount,
                         sustainLevel,
                         releaseAmount)
            }
            lastPoint = touchLocation
        }
        setNeedsDisplay()
    }

    // MARK: - Drawing

    /// Draw the ADSR envelope
    func drawCurveCanvas(size: CGSize = CGSize(width: 440, height: 151),
                         attackAmount: CGFloat = 0.5,           // normalised
                         decayAmount: CGFloat = 0.5,            // normalised
                         sustainLevel: CGFloat = 0.583,         // normalised
                         releaseAmount: CGFloat = 0.5,          // normalised
                         attackPadPercentage: CGFloat = 0.1,    // how much % width of the view should pad attack
                         releasePadPercentage: CGFloat = 0.1,   // how much % width of the view should pad attack
                         attackCurveAmount: CGFloat = 1.0,      // how much % width of the view should pad attack
                         decayCurveAmount: CGFloat = 1.0,       // how much % width of the view should pad attack
                         releaseCurveAmount: CGFloat = 1.0,     // how much curve to apply
                         attackPointPlacement: CGFloat = 0.5
    )
    {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        let width = floor(size.width)
        let height = floor(size.height)

        //// Variable Declarations
        let buffer = CGFloat(10) // curveStrokeWidth / 2.0 // make a little room for drwing the stroke
        let attackClickRoom = floor(CGFloat(attackPadPercentage * width)) // to allow attack to be clicked even if zero
        let releaseClickRoom = floor(CGFloat(releasePadPercentage * width)) // to allow attack to be clicked even if zero
        let endPointMax = width - releaseClickRoom
        let sectionMax = floor((width * (1.0 - attackPadPercentage - releasePadPercentage)) / 3.3)
        let attackSize = floor(attackAmount * sectionMax)
        let decaySize = floor(decayAmount * sectionMax)
        let sustainSize = floor(sustainLevel * (height - buffer) + buffer)
        let releaseSize = releaseAmount * sectionMax

        let initialPoint = CGPoint(x: attackClickRoom, y: height)
        let endAxes = CGPoint(x: width, y: height)
        let releasePoint = CGPoint(x: endPointMax - sectionMax,
                                   y: sustainSize)
        let endPoint = CGPoint(x: min(endPointMax, (releasePoint.x + releaseSize)), y: height)
        let endMax = CGPoint(x: min(endPoint.x, endPointMax), y: buffer)
        let releaseAxis = CGPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = CGPoint(x: releasePoint.x, y: buffer)
        let highPoint = CGPoint(x: attackClickRoom + attackSize, y: buffer)
        let highPointAxis = CGPoint(x: highPoint.x, y: height)
        let highMax = CGPoint(x: highPoint.x, y: buffer)
        let sustainPoint = CGPoint(x: max(highPoint.x, attackClickRoom + attackSize + decaySize),
                                   y: sustainSize)
        let sustainAxis = CGPoint(x: sustainPoint.x, y: height)
        let initialMax = CGPoint(x: 0, y: buffer)

        let initialToHighControlPoint = CGPoint(x: initialPoint.x, y: highPoint.y)
        let highToSustainControlPoint = CGPoint(x: highPoint.x, y: sustainPoint.y)
        let releaseToEndControlPoint = CGPoint(x: releasePoint.x, y: endPoint.y)

        let curve1ControlPoint = CGPoint(x: (attackCurveAmount * initialToHighControlPoint.x)
                                            + ((1.0 - attackCurveAmount) * initialPoint.x),
                                         y: (attackCurveAmount * initialToHighControlPoint.y)
                                            + ((1.0 - attackCurveAmount) * initialPoint.y))

        let curve2ControlPoint = CGPoint(x: (decayCurveAmount * highToSustainControlPoint.x)
                                            + ((1.0 - decayCurveAmount) * highPoint.x),
                                         y: (decayCurveAmount * highToSustainControlPoint.y)
                                            + ((1.0 - decayCurveAmount) * highPoint.y))

        let curve3ControlPoint = CGPoint(x: (releaseCurveAmount * releaseToEndControlPoint.x)
                                            + ((1.0 - releaseCurveAmount) * releasePoint.x),
                                         y: (releaseCurveAmount * releaseToEndControlPoint.y)
                                            + ((1.0 - releaseCurveAmount) * releasePoint.y))

        //// attackTouchArea Drawing
        context?.saveGState()

        attackTouchAreaPath = UIBezierPath()
        attackTouchAreaPath.move(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.addLine(to: highPointAxis)
        attackTouchAreaPath.addLine(to: highMax)
        attackTouchAreaPath.addLine(to: initialMax)
        attackTouchAreaPath.addLine(to: CGPoint(x: 0, y: size.height))
        attackTouchAreaPath.close()
        bgColor.setFill()
        attackTouchAreaPath.fill()

        context?.restoreGState()

        //// decaySustainTouchArea Drawing
        context?.saveGState()

        decaySustainTouchAreaPath = UIBezierPath()
        decaySustainTouchAreaPath.move(to: highPointAxis)
        decaySustainTouchAreaPath.addLine(to: releaseAxis)
        decaySustainTouchAreaPath.addLine(to: releaseMax)
        decaySustainTouchAreaPath.addLine(to: highMax)
        decaySustainTouchAreaPath.addLine(to: highPointAxis)
        decaySustainTouchAreaPath.close()
        bgColor.setFill()
        decaySustainTouchAreaPath.fill()

        context?.restoreGState()

        //// releaseTouchArea Drawing
        context?.saveGState()

        releaseTouchAreaPath = UIBezierPath()
        releaseTouchAreaPath.move(to: releaseAxis)
        releaseTouchAreaPath.addLine(to: endAxes)
        releaseTouchAreaPath.addLine(to: endMax)
        releaseTouchAreaPath.addLine(to: releaseMax)
        releaseTouchAreaPath.addLine(to: releaseAxis)
        releaseTouchAreaPath.close()
        bgColor.setFill()
        releaseTouchAreaPath.fill()

        context?.restoreGState()

        //// releaseArea Drawing
        context?.saveGState()

        let releaseAreaPath = UIBezierPath()
        releaseAreaPath.move(to: releaseAxis)
        releaseAreaPath.addCurve(to: endPoint,
                                 controlPoint1: releaseAxis,
                                 controlPoint2: endPoint)
        releaseAreaPath.addCurve(to: releasePoint,
                                 controlPoint1: curve3ControlPoint,
                                 controlPoint2: releasePoint)
        releaseAreaPath.addLine(to: releaseAxis)
        releaseAreaPath.close()
        if useGradient {
            context?.drawLinearGradient(in: releaseAreaPath.cgPath, startingWith: sustainColor.cgColor,
                                        finishingWith: releaseColor.cgColor)

        } else {
            releaseColor.setFill()
            releaseAreaPath.fill()
        }

        context?.restoreGState()

        //// sustainArea Drawing
        context?.saveGState()

        let sustainAreaPath = UIBezierPath()
        sustainAreaPath.move(to: sustainAxis)
        sustainAreaPath.addLine(to: releaseAxis)
        sustainAreaPath.addLine(to: releasePoint)
        sustainAreaPath.addLine(to: sustainPoint)
        sustainAreaPath.addLine(to: sustainAxis)
        sustainAreaPath.close()
        sustainColor.setFill()
        sustainAreaPath.fill()

        context?.restoreGState()

        //// decayArea Drawing
        context?.saveGState()

        let decayAreaPath = UIBezierPath()
        decayAreaPath.move(to: highPointAxis)
        decayAreaPath.addLine(to: sustainAxis)
        decayAreaPath.addCurve(to: sustainPoint,
                               controlPoint1: sustainAxis,
                               controlPoint2: sustainPoint)
        decayAreaPath.addCurve(to: highPoint,
                               controlPoint1: curve2ControlPoint,
                               controlPoint2: highPoint)
        decayAreaPath.addLine(to: highPoint)
        decayAreaPath.close()
        if useGradient {
            context?.drawLinearGradient(in: decayAreaPath.cgPath, startingWith: decayColor.cgColor,
                                        finishingWith: sustainColor.cgColor)

        } else {
            decayColor.setFill()
            decayAreaPath.fill()
        }

        context?.restoreGState()

        //// attackArea Drawing
        context?.saveGState()

        let attackAreaPath = UIBezierPath()
        attackAreaPath.move(to: initialPoint)
        attackAreaPath.addLine(to: highPointAxis)
        attackAreaPath.addLine(to: highPoint)
        attackAreaPath.addCurve(to: initialPoint,
                                controlPoint1: curve1ControlPoint,
                                controlPoint2: initialPoint)
        attackAreaPath.close()
        if useGradient {
            context?.drawLinearGradient(in: attackAreaPath.cgPath, startingWith: attackColor.cgColor,
                                        finishingWith: decayColor.cgColor)

        } else {
            attackColor.setFill()
            attackAreaPath.fill()
        }

        context?.restoreGState()

        //// Curve Drawing
        context?.saveGState()

        let curvePath = UIBezierPath()
        curvePath.move(to: initialPoint)
        curvePath.addCurve(to: highPoint,
                           controlPoint1: initialPoint,
                           controlPoint2: curve1ControlPoint)
        curvePath.addCurve(to: sustainPoint,
                           controlPoint1: highPoint,
                           controlPoint2: curve2ControlPoint)
        curvePath.addLine(to: releasePoint)
        curvePath.addCurve(to: endPoint,
                           controlPoint1: releasePoint,
                           controlPoint2: curve3ControlPoint)
        curveColor.setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        context?.restoreGState()
    }

    /// Draw the view
    override public func draw(_ rect: CGRect) {
        drawCurveCanvas(size: rect.size,
                        attackAmount: CGFloat(attackAmount),
                        decayAmount: CGFloat(decayAmount),
                        sustainLevel: 1.0 - CGFloat(sustainLevel),
                        releaseAmount: CGFloat(releaseAmount),
                        attackPadPercentage: attackPaddingPercent,
                        releasePadPercentage: releasePaddingPercent,
                        attackCurveAmount: CGFloat(attackCurveAmount),
                        decayCurveAmount: CGFloat(decayCurveAmount),
                        releaseCurveAmount: CGFloat(releaseCurveAmount))
    }
}

extension CGContext {

    private func generateGradient( startColor: CGColor,
                                   endColor: CGColor) -> CGGradient? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [0.0, 1.0] as [CGFloat]
        let colors = [startColor, endColor] as CFArray
        return CGGradient( colorsSpace: colorSpace, colors: colors, locations: locations)
    }

    private func getStartAndEndPoint(rect: CGRect, horizontal: Bool = true) -> (CGPoint, CGPoint) {
        let startPoint = CGPoint(x: horizontal ? rect.minX : rect.midX, y: horizontal ? rect.midY : rect.minY)
        let endPoint = CGPoint(x: horizontal ? rect.maxX : rect.midX, y: horizontal ?  rect.midY : rect.maxY)
        return (startPoint, endPoint)
    }

    private func clipAndDrawGradient(gradient: CGGradient, startPoint: CGPoint, endPoint: CGPoint) {
        clip()
        drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: CGGradientDrawingOptions()
        )
    }

    func drawLinearGradient(
        in path: CGPath,
        startingWith startColor: CGColor,
        finishingWith endColor: CGColor,
        horizontal: Bool = true
    ) {
        guard let gradient = generateGradient(startColor: startColor, endColor: endColor)
        else { return }
        let rect = path.boundingBox
        let startPoint = getStartAndEndPoint(rect: rect, horizontal: horizontal).0
        let endPoint = getStartAndEndPoint(rect: rect, horizontal: horizontal).1

        saveGState()

        addPath(path)

        clipAndDrawGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)

        restoreGState()
    }

    func drawLinearGradient(
        in rect: CGRect,
        startingWith startColor: CGColor,
        finishingWith endColor: CGColor,
        horizontal: Bool = true
    ) {
        guard let gradient = generateGradient(startColor: startColor, endColor: endColor)
        else { return }
        let startPoint = getStartAndEndPoint(rect: rect, horizontal: horizontal).0
        let endPoint = getStartAndEndPoint(rect: rect, horizontal: horizontal).1

        saveGState()

        addRect(rect)

        clipAndDrawGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)

        restoreGState()
    }
  }
}
