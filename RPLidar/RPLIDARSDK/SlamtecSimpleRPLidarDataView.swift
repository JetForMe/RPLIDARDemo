//
//  SlamtecSimpleRPLidarDataView.swift
//  RPLidar
//
//  Created by Rick Mann on 2019-06-04.
//  Copyright © 2019 Latency: Zero, LLC. All rights reserved.
//

import Cocoa



class
SlamtecSimpleRPLidarDataView: NSView
{
	override
	func
	resize(withOldSuperviewSize inOldSize: NSSize)
	{
		super.resize(withOldSuperviewSize: inOldSize)
		
		//	Set the display scale. The RPLIDAR has a 12 m range,
		//	make the widest dimesion 12 m…
		
		let d = min(self.bounds.width, self.bounds.height)
		self.scale = d / 2.0 / 12.0			//	TODO: Make 12.0 configurable
		
		self.needsDisplay = true
	}
	
	override
	func draw(_ inDirtyRect: NSRect)
	{
		super.draw(inDirtyRect)
		
		guard
			let ms = self.measurements,
			let ctx = NSGraphicsContext.current?.cgContext
		else
		{
			return
		}

		let b = self.bounds
		ctx.setFillColor(gray: 1.0, alpha: 1.0)
		ctx.fill(inDirtyRect)
		
		//	Draw the scale…
		
		ctx.setStrokeColor(gray: 0.0, alpha: 1.0)
		
		ctx.move(to: CGPoint(x: b.minX, y: b.midY))
		ctx.addLine(to: CGPoint(x: b.maxX, y: b.midY))
		ctx.move(to: CGPoint(x: b.midX, y: b.minY))
		ctx.addLine(to: CGPoint(x: b.midX, y: b.maxY))
		ctx.strokePath()
		
		let center = CGPoint(x: b.midX, y: b.midY)
		for r in 1...12			//	TODO: Make 12 (max range) configurable
		{
			ctx.addArc(center: center, radius: self.scale * CGFloat(r), startAngle: 0.0, endAngle: CGFloat.pi * 2, clockwise: false)
		}
		ctx.strokePath()
		
		
		if self.count > ms.count
		{
			print("WTF self \(self.count) > ms \(ms.count)")
			return
		}
		
//		print("\(self.count) points")
//		for i in 0..<5
//		{
//			let angle = Float(ms[i].angle_z_q14) * 90.0 / Float(1 << 14)
//			let sync: Bool = ms[i].flag & RPLIDAR_RESP_MEASUREMENT_SYNCBIT
//			print("Value: \(angle)")
//		}
		
		
		ctx.setFillColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
		for idx in 0 ..< self.count
		{
			let m = ms[idx]
			if m.distance < 0.0001
			{
//				print("\(idx) distance \(m.distance) flags \(m.flag)")
				continue
			}
			
			let a: CGFloat = CGFloat(m.angle + Double.pi/2)
			let d: CGFloat = CGFloat(m.distance) * scale
			
			let x: CGFloat = d * cos(a)
			let y: CGFloat = d * sin(a)
			let pt = CGPoint(x: x + center.x, y: y + center.y)
			ctx.addArc(center: pt, radius: 1.0, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
			ctx.fillPath()
		}
	}
	
	var			measurements: [RPLidarMeasurementHQ]?			{ didSet { self.needsDisplay = true } }
	var			count									=	0
	var			scale		:	CGFloat					=	100.0		//	Pixels per meter
}



extension
RPLidarMeasurementHQ
{
	var angle: Double { get { return Double(self.angle_z_q14) / Double(1<<14) * -Double.pi/2 } }
	var distance: Double { get { return Double(self.dist_mm_q2) / 1000.0 } }
	var isSync: Bool { get { return self.flag & UInt8(1 << 0) > 0 } }
}
