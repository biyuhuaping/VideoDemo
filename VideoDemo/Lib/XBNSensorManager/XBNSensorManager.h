//
//  XBNSensorManager.h
//  DemoGoogleMap
//
//  Created by ZhaoDongBo on 2016/9/28.
//  Copyright © 2016年 ZhaoDongBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLHeading.h>
#import <CoreMotion/CoreMotion.h>

@interface XBNSensorManager : NSObject

+ (instancetype)sharedInstance;

- (void)startSensor;
- (void)stopSensor;

- (void)startGyroscope;
- (void)stopGyroscope;

@property (nonatomic, copy) void (^didUpdateHeadingBlock)(CLLocationDirection theHeading);
@property (nonatomic, copy) void (^updateDeviceMotionBlock)(CMDeviceMotion *data);

@end
