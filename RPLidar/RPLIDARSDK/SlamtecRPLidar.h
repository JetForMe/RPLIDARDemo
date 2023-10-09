//
//  SlamtecRPLidar.h
//  RPLidar
//
//  Created by Rick Mann on 2019-06-04.
//  Copyright © 2019 Latency: Zero, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


typedef struct RPLidarMeasurementHQ {
    uint16_t   angle_z_q14;
    uint32_t   dist_mm_q2;
    uint8_t    quality;
    uint8_t    flag;
} __attribute__((packed)) RPLidarMeasurementHQ;

//typedef struct RPLidarMeasurement {
//	uint8_t			sync_quality;			// syncbit:1;syncbit_inverse:1;quality:6;
//	uint16_t		angle_q6_checkbit;		// check_bit:1;angle_q6:15;
//	uint16_t		distance_q2;
//} __attribute__((packed)) RPLidarMeasurement;



@interface
SlamtecRPLidar : NSObject



- (BOOL)				connect: (NSError**) outError;
- (void)				startMotor;
- (void)				stopMotor;
- (BOOL)				startScan: (NSError**) outError;
- (NSInteger)			grabScanData: (RPLidarMeasurementHQ*) ioData error: (NSError**) outError __attribute__((swift_error(nonnull_error)));
//- (float)				getFrequency: (NSInteger) inCount error: (NSError**) outError __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(getFrequency(count:));
- (void)				stop;

@end






typedef
NS_ENUM(NSInteger, RPLIDARError)
{
	RPLIDARErrorNone						=	0,
	RPLIDARErrorInvalidData					=	1,
	RPLIDARErrorFail						=	2,
	RPLIDARErrorTimeout						=	3,
	RPLIDARErrorStop						=	4,
	RPLIDARErrorOperationNotSupported		=	5,
	RPLIDARErrorFormatNotSupported			=	6,
	RPLIDARErrorInsufficientMemory			=	7,
};



NS_ASSUME_NONNULL_END
