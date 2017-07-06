//
//  TimePicker.h
//  Zen Sleep
//
//  Created by Ditriol Wei on 13/3/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TimePickerDelegate;
@interface TimePicker : UIView

@property (assign, nonatomic) id<TimePickerDelegate> delegate;

@property (assign, nonatomic) NSInteger hour;       //[0, 24)
@property (assign, nonatomic) NSInteger minute;

- (void)setHour:(NSInteger)h Minute:(NSInteger)m;
@end


@protocol TimePickerDelegate <NSObject>
@optional
- (void)timePickerDidStartSelection:(TimePicker *)picker;
- (void)timePickerDidSelectTime:(TimePicker *)picker;
@end