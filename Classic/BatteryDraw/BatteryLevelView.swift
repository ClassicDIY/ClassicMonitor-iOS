//https://stackoverflow.com/questions/44766296/place-the-filled-battery-inside-the-image-accurately-so-it-scales-and-aligns-for

import UIKit

@IBDesignable
class BatteryLevelView: UIView {

    @IBInspectable var batteryLevel: CGFloat = 0.6 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        drawLevel(batteryLevel: batteryLevel)
    }

    func drawLevel(batteryLevel: CGFloat = 0.6) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!


        //// Variable Declarations
        let width: CGFloat = 334 * batteryLevel
        let batteryLabelText = "\(Int(round(batteryLevel * 100)))" + "%"

        //// White Rectangle Drawing
        let whiteRectanglePath = UIBezierPath(rect: CGRect(x: 24.5, y: 20.5, width: 334, height: 118))
        UIColor.white.setFill()
        whiteRectanglePath.fill()
        UIColor.black.setStroke()
        whiteRectanglePath.lineWidth = 5
        whiteRectanglePath.stroke()


        //// Green Rectangle Drawing
        let greenRectangleRect = CGRect(x: 24.5, y: 20.5, width: width, height: 118)
        let greenRectanglePath = UIBezierPath(rect: greenRectangleRect)
        UIColor.green.setFill()
        greenRectanglePath.fill()
        UIColor.black.setStroke()
        greenRectanglePath.lineWidth = 5
        greenRectanglePath.stroke()
        let greenRectangleStyle = NSMutableParagraphStyle()
        greenRectangleStyle.alignment = .center
        let greenRectangleFontAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 12)!,
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.paragraphStyle: greenRectangleStyle,
            ]

        let greenRectangleTextHeight: CGFloat = batteryLabelText.boundingRect(with: CGSize(width: greenRectangleRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: greenRectangleFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: greenRectangleRect)
        batteryLabelText.draw(in: CGRect(x: greenRectangleRect.minX, y: greenRectangleRect.minY + (greenRectangleRect.height - greenRectangleTextHeight) / 2, width: greenRectangleRect.width, height: greenRectangleTextHeight), withAttributes: greenRectangleFontAttributes)
        context.restoreGState()


        //// Outer Rectangle Drawing
        let outerRectanglePath = UIBezierPath(roundedRect: CGRect(x: 7, y: 7, width: 372, height: 146), cornerRadius: 20)
        UIColor.black.setStroke()
        outerRectanglePath.lineWidth = 12
        outerRectanglePath.stroke()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 396, y: 53))
        bezierPath.addLine(to: CGPoint(x: 396, y: 109))
        bezierPath.addLine(to: CGPoint(x: 407, y: 98))
        bezierPath.addLine(to: CGPoint(x: 407, y: 64))
        bezierPath.addLine(to: CGPoint(x: 396, y: 53))
        bezierPath.close()
        UIColor.gray.setFill()
        bezierPath.fill()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 12
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.stroke()
    }


}
