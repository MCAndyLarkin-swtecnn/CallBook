//
//  TitleCircle.swift
//  callBook
//
//  Created by user on 05.04.2021.
//

import UIKit
class TitleCircleView: UIButton {
    var fillColor: UIColor = UIColor.green
    var strokeColor: UIColor = UIColor.darkGray
    var textColor: UIColor = UIColor.darkGray
    
    lazy var localCenter = CGPoint(x: frame.width/2, y: frame.height/2)
    
    func collapsed() -> Bool{
        spacerWidth <= 0
    }
    var spacerWidth: CGFloat = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var text: String?{
        didSet{
            textSize = frame.height/TitleCircleView.textProportion
            rad = min(frame.height, frame.width)/2 - def/2
            if let text = text{
                d_max = getNsString(text: text).size().width - getNsString(text: prepare(text: text, in: 0)).size().width
            }
        }
    }
    var d_max: CGFloat?
    
    var textSize: CGFloat?
    var proportion: CGFloat?
    
    var pathWidth = CGFloat( 1 )
    var def = CGFloat(10)
    
    var rad: CGFloat!
    
    static let textProportion = pow(CGFloat(1.618), 1.618)
    
    override func draw(_ rect: CGRect) {
        fillColor = UIColor(hue: CGFloat(Float.random(in: 0...100)), saturation: 0.5, brightness: 1, alpha: 0.8)
        
        if let d_max = d_max{
            proportion = min( d_max, spacerWidth ) / d_max
            if spacerWidth != 0{
                drawSpacier(width: spacerWidth, height: rad*2)
            }
        }
        if let rad = rad{
            drawArc(center: CGPoint(x: localCenter.x-spacerWidth/2, y: localCenter.y), rad: rad, direct: .letf)
            drawArc(center: CGPoint(x: localCenter.x+spacerWidth/2, y: localCenter.y), rad: rad, direct: .right)
        }
        if let proportion = proportion, let text = text{
            drawText(text: getNsString(text: prepare(text: text, in: proportion)))
        }
    }
    private func drawText(text: NSAttributedString){
        text.draw(at: CGPoint(x: localCenter.x-text.size().width/2, y: localCenter.y-text.size().height/2))
    }
    private func drawArc(center: CGPoint, rad: CGFloat,direct: Direction){
        var (startAng, endAng) = (CGFloat.pi/2, -CGFloat.pi/2)
        if direct == .right{
            (startAng, endAng) = (endAng, startAng)
        }
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: center.x, y: center.y), radius: rad, startAngle: startAng, endAngle: endAng, clockwise: true)
        fillColor.setFill()
        path.fill()
        path.lineWidth = pathWidth
        strokeColor.setStroke()
        path.stroke()
    }
    private func prepare(text: String, in proportion: CGFloat) -> String{
        var newText = text.capitalized
        if proportion < 1{
            let textArray = newText.split(separator: " ").prefix(2)
            if proportion > 0{
                newText = textArray
                    .map{ word in
                        word.prefix( Int(proportion * CGFloat(word.count)  ) + 1)
                    }.joined(separator: " ")
            }else{
                newText = textArray
                    .map{ word in
                        word.prefix(1)
                    }.joined()
            }
        }
        return newText
    }
    private func drawSpacier(width: CGFloat, height: CGFloat){
        let (leftTop, rightTop, rightBot, leftBot) = (
            CGPoint(x: localCenter.x-width/2, y: localCenter.y+height/2),
            CGPoint(x: localCenter.x+width/2, y: localCenter.y+height/2),
            CGPoint(x: localCenter.x-width/2, y: localCenter.y-height/2),
            CGPoint(x: localCenter.x+width/2, y: localCenter.y-height/2))
        
        let redPath = UIBezierPath()
        redPath.move(to: leftTop)
        redPath.addLine(to: rightTop)
        redPath.move(to: leftBot)
        redPath.addLine(to: rightBot)
        
        redPath.lineWidth = pathWidth
        strokeColor.setStroke()
        redPath.stroke()
        fillColor.setFill()
        redPath.fill()
        
        let greenPath = UIBezierPath()
        greenPath.move(to: leftTop)
        greenPath.addLine(to: rightTop)
        greenPath.addLine(to: leftBot)
        greenPath.addLine(to: rightBot)
        greenPath.close()
        
        fillColor.setFill()
        greenPath.fill()
    }
    private func getNsString(text: String) -> NSAttributedString{
        return NSAttributedString(string: text,
                                  attributes: [
                                    NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: textSize!),
                                    NSAttributedString.Key.foregroundColor: textColor])
    }
}
enum Direction{
    case letf
    case right
}
