//
//  AppDelegate.m
//  Light
//
//  Created by Karl Faust on 3/16/16.
//  Copyright © 2016 company. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate (){
    UIBackgroundTaskIdentifier backgroundtaskIdentifierObj;
}

@end

@implementation AppDelegate

@synthesize myplayer, bgTime;

@synthesize alarmNotification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Override point for customization after application launch.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        alarmNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];

        if (alarmNotification) {
            [application cancelAllLocalNotifications];
        }else{

        }
    }
    alarmNotification = [[UILocalNotification alloc] init];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"localNotificationReceived" object:alarmNotification.userInfo];

    //Background Fetching
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    ////////
   //////////background play audio setting////////////
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    ////////////////////////////////////////////////
    
    // Local notification for opening the app in background task using alert
    UILocalNotification *localNoti = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNoti) {
        [application cancelAllLocalNotifications];
    }
    
    //register notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSuspendNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    
    ////////////////////////////////////////////////////////////////////////////////
    //To stop the app from timing out and going to sleep
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    ///////////////////////////////////////////////////////////////////////
    
    [self prepareBgAudio];
    
    //Detecting when the device is connected to charger or not
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[UIDevice currentDevice] batteryLevel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBatteryState) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBatteryState) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"Received Background Fetch");
    
    NSDate *fetchStart = [NSDate date];
    
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    
    [viewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
        
    }];
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    [notification setRepeatInterval:0.0f];
//    [notification setAlertBody:[NSString stringWithFormat:@"Fetch Success: %@", [NSDate date]]];
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"Will Resign Active...");
    
    //init bg time count
    bgTime = 0;
    
    is_interruption = false;
    
    [self runBackgroundTasK];
    
    ////////////////////
    [self addNSNotifications];
    ////////////////////
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [self pushLocalNotificationForLogWithText:@"Background"];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    NSLog(@"Did Enter Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Will Enter Forground");
    
    [self stopBgTasks];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Did Become Active");
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Will Terminate");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    
    NSLog(@"Received Location Notification!");
//    if ([application applicationState] == UIApplicationStateInactive) {
    if ([notification isEqual:alarmNotification]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"localNotificationReceived" object:notification.userInfo];
    }
//    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - 

-(void)addNSNotifications{
    [self setAudioInterruptionNotify];
}

-(void)setAudioInterruptionNotify{
    NSOperationQueue *mainQueue1 = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_TYPE_4 object:nil queue:mainQueue1 usingBlock:^(NSNotification *note) {
        NSUInteger type = [[note.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        
        if (type == AVAudioSessionInterruptionTypeBegan) {
            is_interruption = true;
            [self startInterruptionTask];
        } else if (type == AVAudioSessionInterruptionTypeEnded) {
            is_interruption = false;
            [self endInterruptionTask];
        }else{
            NSLog(@"other");
        }
        
    }];
}

-(void)startInterruptionTask{
    [myplayer stop];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        call_timer = [NSTimer scheduledTimerWithTimeInterval:175 target:self selector:@selector(replayMyAudio) userInfo:nil repeats:NO];
    });
}

-(void)endInterruptionTask{
    [self replayMyAudio];
    
    [call_timer invalidate];
    call_timer = nil;
}

-(void)replayMyAudio{
    
    if ([myplayer isPlaying] == false) {
        [self prepareBgAudio];
        [myplayer play];
    }
    
    if(backgroundtaskIdentifierObj == UIBackgroundTaskInvalid){
        [self runBackgroundTasK];
    }
    
    if ([myplayer isPlaying] == false) {
//        [self requestGetData];
    }else{
        is_interruption = false;
    }
    
}


//////////////////
-(void)prepareBgAudio{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:AUDIO_NAME
                                         ofType:@"mp3"]];
    NSError *sessionError = nil;
    myplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&sessionError]; //AVAudioSessionCategoryPlayAndRecord
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers  error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    [myplayer prepareToPlay];
    [myplayer setDelegate:self];
    myplayer.numberOfLoops = -1;
    [myplayer setVolume:0.0000];
}

-(void)receiveSuspendNotification:(NSNotification *)noti{
    NSLog(@"SuspendNotification is received");
}

-(BOOL) running
{
    if(backgroundtaskIdentifierObj == UIBackgroundTaskInvalid)
        return FALSE;
    return TRUE;
}

-(void)runBackgroundTasK{
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if([self running])
                           [self stopBgTasks];
                       
                       while([self running])
                       {
                           [NSThread sleepForTimeInterval:1];
                       }
                       [self bgTask];
                       
                   });
}


-(void)stopBgTasks{
    
    
    //when application become foreground state, kill timer
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    //stop background task
    if ([myplayer isPlaying]) {
        [myplayer stop];
    }
    
    if(backgroundtaskIdentifierObj != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundtaskIdentifierObj];
        backgroundtaskIdentifierObj=UIBackgroundTaskInvalid;
    }
}

-(void)bgTask{
    backgroundtaskIdentifierObj = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundtaskIdentifierObj];
        backgroundtaskIdentifierObj = UIBackgroundTaskInvalid;
        
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    // long time background task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [myplayer play];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(bgCallback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        
        //        [self sendPushNotification:@"timer - bgTask 2"];
        
        backgroundtaskIdentifierObj = UIBackgroundTaskInvalid;
    });
}

-(void)bgCallback{
    
    //check screenshot detected or not
//    [self getLastPhoto];
    
    bgTime++;
    NSLog(@"%ld", (long)bgTime);
}

- (void)checkBatteryState {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        
        self.isConnectedCharger = NO;
        [self pushLocalNotificationForLogWithText:@"Uplamp is ready!"];
        
    }else if (self.isConnectedCharger == NO) {
        
        self.isConnectedCharger = YES;
        [self pushLocalNotificationForLogWithText:@"Uplamp is ready!"];
        
    }
}

- (void)pushLocalNotificationForLogWithText: (NSString *)body {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        [notification setRepeatInterval:0.0f];
        [notification setAlertBody:[NSString stringWithFormat:@"%@: %@", body, [NSDate date]]];
        
        NSLog(@"%@", notification.alertBody);
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

@end
