//
//  ViewController.h
//  Light
//
//  Created by Karl Faust on 3/16/16.
//  Copyright © 2016 company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property NSInteger backgroundTime;

- (void)scheduleLocalNotificationWithDate: (NSDate *)date;

- (void)fetchNewDataWithCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler;

@end

