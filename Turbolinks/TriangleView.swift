//
//  TriangleView.swift
//  Turbolinks
//
//  Created by Victor Sima on 10/2/18.
//
import UIKit

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        let ctx : CGContext = UIGraphicsGetCurrentContext()!
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.minX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        ctx.closePath()

        ctx.setFillColor(UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor)
        ctx.fillPath()
    }
}
