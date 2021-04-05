//
//  TitleCircle.swift
//  callBook
//
//  Created by user on 05.04.2021.
//

import UIKit
class TitleCircleView: UIButton {
    var pathWidth = CGFloat( 1 )
    var def = CGFloat(10)
    var fillColor: UIColor = UIColor.green
    var strokeColor: UIColor = UIColor.darkGray
    var textColor: UIColor = UIColor.darkGray
    var text: String = ""{
        didSet{
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        fillColor = UIColor(hue: CGFloat(Float.random(in: 0...100)), saturation: 0.5, brightness: 1, alpha: 0.8)
        drawContactTitleView(text: self.text, mode: .tiny, rect: rect)
    }
    func drawContactTitleView(text: String, mode: Mode, rect: CGRect){
        let width = min(rect.height, rect.width)
        let (centerX, centerY) = (rect.width/2, rect.height/2)
        let rad = width/2-def/2
        var spacerWidth: CGFloat = 0
        var text = text
        print("\(text)")
        if mode == .tiny{
            text = text.split(separator: " ").map{
                word in
                word.prefix(1).uppercased()
            }.joined()
        }
        let attr = [ NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 30.0),
                     NSAttributedString.Key.foregroundColor: textColor]
        let nsText = NSAttributedString(string: text, attributes: attr)
        if mode == .full{
            spacerWidth = nsText.size().width - def
            drawSpacier(center: CGPoint(x: centerX, y: centerY), width: spacerWidth, height: rad*2)
        }
        
        drawArc(center: CGPoint(x: centerX-spacerWidth/2, y: centerY), rad: rad, direct: .letf)
        drawArc(center: CGPoint(x: centerX+spacerWidth/2, y: centerY), rad: rad, direct: .right)
        
        drawText(text: nsText, center: CGPoint(x: centerX, y: centerY))
    }
    func drawText(text: NSAttributedString, center: CGPoint){
        text.draw(at: CGPoint(x: center.x-text.size().width/2, y: center.y-text.size().height/2))
    }
    func drawArc(center: CGPoint, rad: CGFloat,direct: Direction){
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
    func drawSpacier(center: CGPoint, width: CGFloat, height: CGFloat){
        let (leftTop, rightTop, rightBot, leftBot) = (
            CGPoint(x: center.x-width/2, y: center.y+height/2),
            CGPoint(x: center.x+width/2, y: center.y+height/2),
            CGPoint(x: center.x-width/2, y: center.y-height/2),
            CGPoint(x: center.x+width/2, y: center.y-height/2))
        
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
}
enum Direction{
    case letf
    case right
}

enum Mode{
    case tiny
    case full
}
