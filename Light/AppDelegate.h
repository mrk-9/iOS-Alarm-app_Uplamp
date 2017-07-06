//
//  AppDelegate.h
//  Light
//
//  Created by Karl Faust on 3/16/16.
//  Copyright © 2016 company. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIMER_INTERVAL   2
#define AUDIO_NAME       @"silent1" //silent1

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate> {
    NSTimer *timer;
    
    //audio interruption
    NSTimer *call_timer;
    BOOL is_interruption;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AVAudioPlayer *myplayer;

@property (strong, nonatomic) UILocalNotification *alarmNotification;
@property (strong, nonatomic) UILocalNotification *chargerNotification;

//--battery state
@property BOOL isConnectedCharger;

//background time count

@property NSInteger bgTime;

@end

