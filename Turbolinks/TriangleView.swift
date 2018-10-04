//
//  TriangleView.swift
//  Turbolinks
//
//  Created by Victor Sima on 10/2/18.
//
import UIKit

class TriangleView : UIView {
	let color: UIColor
	init(frame: CGRect, color: UIColor) {
		self.color = color
		super.init(frame: frame)
		backgroundColor = .clear
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.color = UIColor.green
		super.init(coder: aDecoder)
	}
	
	override func draw(_ rect: CGRect) {
		
		let ctx : CGContext = UIGraphicsGetCurrentContext()!
		
		ctx.beginPath()
		ctx.move(to: CGPoint(x: rect.minX, y: rect.minY))
		ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
		ctx.closePath()
		
		ctx.setFillColor(color.cgColor)
		ctx.fillPath()
	}
}
