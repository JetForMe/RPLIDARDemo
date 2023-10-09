//
//  SlamtecRPLidar.mm
//  RPLidar
//
//  Created by Rick Mann on 2019-06-04.
//  Copyright © 2019 Latency: Zero, LLC. All rights reserved.
//

#import "SlamtecRPLidar.h"

#import "rplidar.h"



using namespace rp::standalone::rplidar;





@interface SlamtecRPLidar()

@property (nonatomic, assign)	ILidarDriver*			driver;
@property (nonatomic, assign)	RplidarScanMode			mode;

@end













@implementation SlamtecRPLidar



- (instancetype)
init
{
	self = [super init];
	if (self != nil)
	{
		self.driver = *createLidarDriver();
	}
	
	return self;
}

- (void)
dealloc
{
	delete self.driver;
}

- (BOOL)
connect: (NSError**) outError
{
	Result<IChannel*> channel = createSerialPortChannel("/dev/tty.usbserial-210", 1000000);	//	TODO: Find this!
	auto result = self.driver->connect(*channel);
	if (SL_IS_FAIL(result))
	{
		if (outError != nil)
		{
			*outError = [NSError errorWithDomain: @"RPLIDARError" code: result & 0x7FFF userInfo: nil];
		}
		return false;
	}
	
	std::vector<RplidarScanMode> modes;
	result = self.driver->getAllSupportedScanModes(modes);
	if (SL_IS_FAIL(result))
	{
		if (outError != nil)
		{
			*outError = [NSError errorWithDomain: @"RPLIDARError" code: result & 0x7FFF userInfo: nil];
		}
		return false;
	}
	
	for (auto mode : modes)
	{
		NSLog(@"Mode: %d, %f µs, %f m, %s", mode.id, mode.us_per_sample, mode.max_distance, mode.scan_mode);
	}
	
	return true;
}

- (void)
startMotor
{
	self.driver->setMotorSpeed();
}

- (void)
stopMotor
{
	self.driver->setMotorSpeed(0);
}

- (BOOL)
startScan: (NSError**) outError
{
	RplidarScanMode scanMode;
	u_result result = self.driver->startScanExpress(false, 2, 0, &scanMode);
	self.mode = scanMode;
	return IS_OK(result);
}

- (void)
stop
{
	self.driver->stop();
}



- (NSInteger)
grabScanData: (RPLidarMeasurementHQ*) ioData error: (NSError**) outError
{
	size_t nodeCount = 8192;
//	if (ioData.length < nodeCount)
//	{
//		//	Set outError
//		return 0;
//	}
	
	u_result result = self.driver->grabScanDataHq((rplidar_response_measurement_node_hq_t*) ioData, nodeCount);
	if IS_FAIL(result)
	{
		//	Set outError
		return 0;
	}
	
	return (NSInteger) nodeCount;
}

//- (float)
//getFrequency: (NSInteger) inCount error: (NSError**) outError __attribute__((swift_error(nonnull_error)))
//{
//	float freq;
//	u_result result = self.driver->getFrequency(self.mode, (size_t) inCount, freq);
//	if (IS_FAIL(result))
//	{
//		if (outError != nil)
//		{
//			*outError = [NSError errorWithDomain: @"RPLIDARError" code: result & 0x7FFF userInfo: nil];
//		}
//		return 0.0;
//	}
//	
//	return freq;
//}

@end
