//
//  ViewController.swift
//  RPLidar
//
//  Created by Rick Mann on 2019-06-04.
//  Copyright © 2019 Latency: Zero, LLC. All rights reserved.
//

import Cocoa





class
ViewController: NSViewController
{
	override
	func
	viewDidLoad()
	{
		super.viewDidLoad()
		
		self.lidar = SlamtecRPLidar()
		try! self.lidar.connect()
	}
	
	override
	func
	viewWillAppear()
	{
		super.viewWillAppear()
		
	}
	
	override
	func
	viewDidAppear()
	{
		super.viewDidAppear()
		
		startUpdating()
	}
	
	override
	func
	viewWillDisappear()
	{
		stopUpdating()
		super.viewWillDisappear()
	}
	
	func
	startUpdating()
	{
		self.measurements = [RPLidarMeasurementHQ](repeating: RPLidarMeasurementHQ(), count: 8192)
		
		self.lidar.startMotor()
		try! self.lidar.startScan()
		
		self.scanTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
		{ (inTimer) in
			self.scanQueue.async
			{
				let count = self.update()
				let ms = self.measurements
				DispatchQueue.main.async
				{
					self.dataView.count = count
					self.dataView.measurements = ms
				}
			}
		}
	}
	
	func
	stopUpdating()
	{
		self.lidar.stopMotor()
		self.scanTimer?.invalidate()
		self.measurements = nil
	}
	
	func
	update()
		-> Int
	{
		let count = self.measurements?.withUnsafeMutableBufferPointer
		{ (inBuf: inout UnsafeMutableBufferPointer<RPLidarMeasurementHQ>) -> Int in
			return try! self.lidar.grabScanData(inBuf.baseAddress!)
		}
		
		if let count = count
		{
			let freq = try! self.lidar.getFrequency(count: count)
			print("Freq: \(freq), count: \(count)")
		}
		return Int(count ?? 0)
	}
	
	@IBOutlet weak var dataView: SlamtecSimpleRPLidarDataView!
	
	var			lidar									=	SlamtecRPLidar()
	var			scanTimer: Timer?
	let			scanQueue								=	DispatchQueue(label: "Scan Queue", qos: .background)
	var			measurements: [RPLidarMeasurementHQ]?
	var			count									=	0
}

