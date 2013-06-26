//
//  HDHeadphoneDetector.h
//  CrimePrevention
//
//  Created by MIYAMOTO TATSUYA on 2013/05/26.
//  Copyright (c) 2013年 MIYAMOTO TATSUYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "NotificationNameDefine.h"

@interface HDHeadphoneDetector : NSObject{
}

@property (nonatomic, readonly) BOOL currenstateArePlugged;

- (void)headphoneArePlugged;
- (void)headphoneAreNotPlugged;

@end