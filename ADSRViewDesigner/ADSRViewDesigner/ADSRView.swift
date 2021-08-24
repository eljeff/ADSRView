//
//  ADSRView.swift
//  ADSRViewDesigner
//
//  Created by Jeff Cooper on 8/24/21.
//

import UIKit

class ADSRView: UIView {

    var attackDuration: CGFloat = 408 { didSet { setNeedsDisplay() } }
    var decayDuration: CGFloat = 262 { didSet { setNeedsDisplay() } }
    var sustainLevel: CGFloat = 0.5 { didSet { setNeedsDisplay() } }
    var releaseDuration: CGFloat = 448 { didSet { setNeedsDisplay() } }

    private var minimumSectionSize: CGFloat {
        return frame.width * 0.01
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCurveCanvas(size: rect.size, attackDuration: attackDuration, decayDurationMS: decayDuration,
                        sustainLevel: sustainLevel, releaseDurationMS: releaseDuration, maxADFraction: 0.75)
    }

    func drawCurveCanvas(size: CGSize = CGSize(width: 440, height: 151), attackDuration: CGFloat = 408,
                         decayDurationMS: CGFloat = 262, sustainLevel: CGFloat = 0.583,
                         releaseDurationMS: CGFloat = 448, maxADFraction: CGFloat = 0.75) {
//        print("frame is \(frame) - minSize is \(minimumSectionSize)")
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Color Declarations
        let attackColor = UIColor(red: 0.767, green: 0.000, blue: 0.000, alpha: 1.000)
        let decayColor = UIColor(red: 0.942, green: 0.648, blue: 0.000, alpha: 1.000)
        let sustainColor = UIColor(red: 0.320, green: 0.800, blue: 0.616, alpha: 1.000)
        let releaseColor = UIColor(red: 0.720, green: 0.519, blue: 0.888, alpha: 1.000)
        let backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Variable Declarations
        let oneSecond: CGFloat = 0.7 * size.width
        let initialPoint = CGPoint(x: 0, y: size.height)
        let curveStrokeWidth: CGFloat = min(max(1, size.height / 50.0), max(1, size.width / 100.0))
        let endAxes = CGPoint(x: size.width, y: size.height)
        let releasePoint = CGPoint(x: oneSecond, y: sustainLevel * size.height)
        let endPoint = CGPoint(x: releasePoint.x + releaseDurationMS / 1000.0 * oneSecond, y: size.height + 0)
        let endMax = CGPoint(x: min(endPoint.x, size.width), y: 0)
        let releaseAxis = CGPoint(x: releasePoint.x, y: endPoint.y)
        let releaseMax = CGPoint(x: releasePoint.x, y: 0)
        let highPoint = CGPoint(x: max(0, min(oneSecond * maxADFraction, attackDuration / 1000.0 * oneSecond)), y: 2)
        let highPointAxis = CGPoint(x: highPoint.x, y: size.height)
        let highMax = CGPoint(x: highPoint.x, y: 0)
        let sustainPoint = CGPoint(x: max(highPoint.x, min(oneSecond * maxADFraction, (attackDuration + decayDurationMS) / 1000.0 * oneSecond)), y: sustainLevel * size.height)
        let sustainAxis = CGPoint(x: sustainPoint.x, y: size.height)
        let initialMax = CGPoint(x: 0, y: 0)

        //// attackTouchArea Drawing
        context.saveGState()

        let attackTouchAreaPath = UIBezierPath()
        attackTouchAreaPath.move(to: CGPoint(x: initialPoint.x, y: (initialPoint.y + 1)))
        attackTouchAreaPath.addLine(to: CGPoint(x: highPointAxis.x, y: (highPointAxis.y + 1)))
        attackTouchAreaPath.addLine(to: CGPoint(x: highMax.x, y: (highMax.y + 1)))
        attackTouchAreaPath.addLine(to: CGPoint(x: initialMax.x, y: (initialMax.y + 1)))
        attackTouchAreaPath.addLine(to: CGPoint(x: initialPoint.x, y: (initialPoint.y + 1)))
        attackTouchAreaPath.close()
        backgroundColor.setFill()
        attackTouchAreaPath.fill()

        context.restoreGState()


        //// decaySustainTouchArea Drawing
        context.saveGState()
        context.translateBy(x: 0, y: -1)

        let decaySustainTouchAreaPath = UIBezierPath()
        decaySustainTouchAreaPath.move(to: highPointAxis)
        decaySustainTouchAreaPath.addLine(to: releaseAxis)
        decaySustainTouchAreaPath.addLine(to: releaseMax)
        decaySustainTouchAreaPath.addLine(to: highMax)
        decaySustainTouchAreaPath.addLine(to: highPointAxis)
        decaySustainTouchAreaPath.close()
        backgroundColor.setFill()
        decaySustainTouchAreaPath.fill()

        context.restoreGState()


        //// releaseTouchArea Drawing
        context.saveGState()

        let releaseTouchAreaPath = UIBezierPath()
        releaseTouchAreaPath.move(to: releaseAxis)
        releaseTouchAreaPath.addLine(to: endAxes)
        releaseTouchAreaPath.addLine(to: endMax)
        releaseTouchAreaPath.addLine(to: releaseMax)
        releaseTouchAreaPath.addLine(to: releaseAxis)
        releaseTouchAreaPath.close()
        backgroundColor.setFill()
        releaseTouchAreaPath.fill()

        context.restoreGState()


        //// releaseArea Drawing
        context.saveGState()
        context.translateBy(x: 0, y: -1)

        let releaseAreaPath = UIBezierPath()
        releaseAreaPath.move(to: releaseAxis)
        releaseAreaPath.addCurve(to: endPoint, controlPoint1: releaseAxis, controlPoint2: CGPoint(x: endPoint.x + 35.03, y: endPoint.y))
        releaseAreaPath.addCurve(to: releasePoint, controlPoint1: CGPoint(x: endPoint.x - 140.14, y: endPoint.y), controlPoint2: releasePoint)
        releaseAreaPath.addLine(to: releaseAxis)
        releaseAreaPath.close()
        releaseColor.setFill()
        releaseAreaPath.fill()

        context.restoreGState()


        //// sustainArea Drawing
        context.saveGState()
        context.translateBy(x: 0, y: -1)

        let sustainAreaPath = UIBezierPath()
        sustainAreaPath.move(to: sustainAxis)
        sustainAreaPath.addLine(to: releaseAxis)
        sustainAreaPath.addLine(to: releasePoint)
        sustainAreaPath.addLine(to: sustainPoint)
        sustainAreaPath.addLine(to: sustainAxis)
        sustainAreaPath.close()
        sustainColor.setFill()
        sustainAreaPath.fill()

        context.restoreGState()


        //// decayArea Drawing
        context.saveGState()
        context.translateBy(x: 56, y: 1)

        let decayAreaPath = UIBezierPath()
        decayAreaPath.move(to: CGPoint(x: (highPointAxis.x - 56), y: (highPointAxis.y - 2)))
        decayAreaPath.addLine(to: CGPoint(x: (sustainAxis.x - 56), y: (sustainAxis.y - 2)))
        decayAreaPath.addCurve(to: CGPoint(x: (sustainPoint.x - 56), y: (sustainPoint.y - 2)), controlPoint1: CGPoint(x: (sustainAxis.x - 56), y: (sustainAxis.y - 2)), controlPoint2: CGPoint(x: (sustainPoint.x - 56) + 0.16, y: (sustainPoint.y - 2) + 0.1))
        decayAreaPath.addCurve(to: CGPoint(x: (highPoint.x - 56), y: (highPoint.y - 2)), controlPoint1: CGPoint(x: (sustainPoint.x - 56) - 91, y: (sustainPoint.y - 2) + 0.2), controlPoint2: CGPoint(x: (highPoint.x - 56), y: (highPoint.y - 2)))
        decayAreaPath.addLine(to: CGPoint(x: (highPointAxis.x - 56), y: (highPointAxis.y - 2)))
        decayAreaPath.close()
        decayColor.setFill()
        decayAreaPath.fill()

        context.restoreGState()


        //// attackArea Drawing
        context.saveGState()
        context.translateBy(x: 0, y: -1)

        let attackAreaPath = UIBezierPath()
        attackAreaPath.move(to: CGPoint(x: initialPoint.x, y: (initialPoint.y + 1)))
        attackAreaPath.addLine(to: CGPoint(x: highPointAxis.x, y: (highPointAxis.y + 1)))
        attackAreaPath.addLine(to: CGPoint(x: highPoint.x, y: (highPoint.y + 1)))
        attackAreaPath.addCurve(to: CGPoint(x: initialPoint.x, y: (initialPoint.y + 1)), controlPoint1: CGPoint(x: highPoint.x - 139.45, y: (highPoint.y + 1)), controlPoint2: CGPoint(x: initialPoint.x, y: (initialPoint.y + 1)))
        attackAreaPath.close()
        attackColor.setFill()
        attackAreaPath.fill()

        context.restoreGState()

        //// Curve Drawing
        context.saveGState()
        context.translateBy(x: 0, y: -1)

        let curvePath = UIBezierPath()
        curvePath.move(to: initialPoint)    // first point on curve
        let controlPoint2 = CGPoint(x: initialPoint.x, y: highPoint.y)
        print(controlPoint2)

        curvePath.addCurve(to: highPoint, controlPoint1: initialPoint, controlPoint2: controlPoint2)
        curvePath.addCurve(to: sustainPoint, controlPoint1: highPoint, controlPoint2: CGPoint(x: sustainPoint.x - 90, y: sustainPoint.y + 0.2))
        curvePath.addLine(to: releasePoint)
        curvePath.addCurve(to: endPoint, controlPoint1: releasePoint, controlPoint2: CGPoint(x: endPoint.x - 139.14, y: endPoint.y))
        UIColor.black.setStroke()
        curvePath.lineWidth = curveStrokeWidth
        curvePath.stroke()

        context.restoreGState()
    }


}
