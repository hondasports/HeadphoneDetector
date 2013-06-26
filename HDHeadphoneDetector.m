//
//  HDHeadphoneDetector.m
//  CrimePrevention
//
//  Created by MIYAMOTO TATSUYA on 2013/05/26.
//  Copyright (c) 2013年 MIYAMOTO TATSUYA. All rights reserved.
//
#import "HDHeadphoneDetector.h"

void audioRouteChangeListenerCallback(void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertySize, const void *inPropertyValue);

@implementation HDHeadphoneDetector{
}

- (id)init {
	self = [super init];
	if (self) {
		// オーディオ初期化
		AudioSessionInitialize(NULL, NULL, NULL, NULL);
		AudioSessionAddPropertyListener(
				kAudioSessionProperty_AudioRouteChange,
				audioRouteChangeListenerCallback,
				(__bridge void *)self);
	}
	return self;
}

- (void) headphoneArePlugged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:HEADPHONE_PLUGGED object:self];
}

- (void) headphoneAreNotPlugged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:HEADPHONE_NOT_PLUGGED object:self];
}

- (void) dealloc
{
	AudioSessionRemovePropertyListenerWithUserData(
			kAudioSessionProperty_AudioRouteChange,
			audioRouteChangeListenerCallback,
			(__bridge void *)self);

	DLog(@"HeadPhone Detector dealloc!!!");
}

-(BOOL) currenstateArePlugged
{
	// 情報元 : http://ios-dev-blog.com/how-to-check-that-headphones-are-attached-to-device/
	BOOL result = NO;

	CFStringRef route;
	UInt32 propertySize = sizeof(CFStringRef);
	if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route) == 0)	{
		NSString *routeString = (__bridge_transfer NSString *) route;
		if ([routeString isEqualToString: @"Headphone"] == YES) {
			result = YES;
		}
	}
	return result;
}

void audioRouteChangeListenerCallback(
		void *inUserData,
		AudioSessionPropertyID inPropertyID,
		UInt32 inPropertySize,
		const void *inPropertyValue)
{

	if( inPropertyID != kAudioSessionProperty_AudioRouteChange){
		return;
	}

	CFDictionaryRef routeChangeDictionary = inPropertyValue;

	// オーディを経路変化の理由
	CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
	SInt32 routeChangeReason;
	CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);

	if( routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable ||
        routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable){

		CFStringRef route;
		UInt32 propertySize = sizeof(CFStringRef);
        
		if(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route) == 0){

            HDHeadphoneDetector *headphoneDetector  = (__bridge HDHeadphoneDetector *)inUserData;
            NSString *routeString                   = (__bridge_transfer NSString *)route;

            if([routeString isEqualToString:@"Headphone"] == YES){
                [headphoneDetector headphoneArePlugged];
                NSLog(@"Attached");
            } else {
                [headphoneDetector headphoneAreNotPlugged];
                NSLog(@"Not Attached");
            }
		}
	}
}

@end