//
//  TimePicker.m
//  Zen Sleep
//
//  Created by Ditriol Wei on 13/3/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

//  Size should be ( 300 x 220 )
//  Need "Gotham Thin" font


#import "TimePicker.h"
#import "InfiniteScrollView.h"

#define MAX_PICKER_ROW      (12*1000)

@interface TimePicker () <InfiniteScrollViewDelegate>
@property (strong, nonatomic) InfiniteScrollView * hourScrollView;
@property (strong, nonatomic) InfiniteScrollView * minuScrollView;
@property (strong, nonatomic) UILabel * hourLabel;
@property (strong, nonatomic) UILabel * minuLabel;
@property (strong, nonatomic) UILabel * sepaLabel;
@property (strong, nonatomic) UILabel * amLabel;
@property (strong, nonatomic) UILabel * pmLabel;
@end

@implementation TimePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self != nil )
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self != nil )
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    CGSize s = [self bounds].size;
    
//    [self setBackgroundColor:[UIColor greenColor]];
    
    CGFloat interval = self.frame.origin.x;
    CGFloat myFont = s.height * 2 / 3;
    
    ///showing seperate line
    for (NSInteger i = 0; i < 3; i++) {
        UIView *topV = [[UIView alloc] initWithFrame:CGRectMake(interval + i * s.width / 3, 0, s.width / 3 - interval * 2, 2)];
        [topV setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:topV];
        
        UIView *bottomV = [[UIView alloc] initWithFrame:CGRectMake(interval + i * s.width / 3, s.height - 2, s.width / 3 - interval * 2, 2)];
        [bottomV setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:bottomV];
    }
    
    self.hourScrollView = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(0, - s.height / 4, s.width / 3, s.height * 1.5)];
    _hourScrollView.infiniteScrollViewDelegate = self;
    [_hourScrollView setNumberOfLabel:12 startAtZero:NO];
    _hourScrollView.currentIndex = 3;
    [self addSubview:_hourScrollView];
    
    self.hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, s.width / 3, s.height)];
//    [self.hourLabel setBackgroundColor:[UIColor blackColor]];/////
    _hourLabel.text = [NSString stringWithFormat:@"%02d", (int)3];
    _hourLabel.textColor = [UIColor whiteColor];
    _hourLabel.textAlignment = NSTextAlignmentCenter;
//    _hourLabel.font = [UIFont fontWithName:@"Gotham Thin" size:s.height * 5 / 6];
    [_hourLabel setFont:[UIFont systemFontOfSize:(myFont) weight:UIFontWeightMedium]];
    [self addSubview:_hourLabel];
    
    self.minuScrollView = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(s.width / 3, - s.height / 4, s.width / 3, s.height * 1.5)];
    _minuScrollView.infiniteScrollViewDelegate = self;
    [_minuScrollView setNumberOfLabel:60 startAtZero:YES];
    _minuScrollView.currentIndex = 30;
    [self addSubview:_minuScrollView];
    
    self.minuLabel = [[UILabel alloc] initWithFrame:CGRectMake(s.width / 3, 0, s.width / 3, s.height)];
//    [self.minuLabel setBackgroundColor:[UIColor blackColor]];/////
    _minuLabel.text = [NSString stringWithFormat:@"%02d", (int)30];
    _minuLabel.textColor = [UIColor whiteColor];
    _minuLabel.textAlignment = NSTextAlignmentCenter;
//    _minuLabel.font = [UIFont fontWithName:@"Gotham Thin" size:s.height * 5 / 6];
    [_minuLabel setFont:[UIFont systemFontOfSize:(myFont) weight:UIFontWeightMedium]];
    [self addSubview:_minuLabel];

//    self.sepaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.47*s.width, 0, 0.06*s.width, s.height)];
//    _sepaLabel.text = @":";
//    _sepaLabel.textColor = [UIColor whiteColor];
//    _sepaLabel.textAlignment = NSTextAlignmentCenter;
//    _sepaLabel.font = [UIFont fontWithName:@"Gotham Thin" size:70];
//    [self addSubview:_sepaLabel];
    
    CGRect r1 = [self rectOfAM];
    self.amLabel = [[UILabel alloc] initWithFrame:r1];
    _amLabel.text = @"AM";
    _amLabel.textColor = [UIColor whiteColor];
    _amLabel.textAlignment = NSTextAlignmentCenter;
//    _amLabel.font = [UIFont fontWithName:@"Gotham Thin" size:s.height * 5 / 6];
    [_amLabel setFont:[UIFont systemFontOfSize:(myFont) weight:UIFontWeightMedium]];
    _amLabel.alpha = 1;
    [self addSubview:_amLabel];
    
    CGRect r2 = r1; r2.origin.y-=r2.size.height;
    self.pmLabel = [[UILabel alloc] initWithFrame:r2];
    _pmLabel.text = @"PM";
    _pmLabel.textColor = [UIColor whiteColor];
    _pmLabel.textAlignment = NSTextAlignmentCenter;
//    _pmLabel.font = [UIFont fontWithName:@"Gotham Thin" size:s.height * 5 / 6];
    [_pmLabel setFont:[UIFont systemFontOfSize:(myFont) weight:UIFontWeightMedium]];
    _pmLabel.alpha = 0;
    [self addSubview:_pmLabel];
    
    [self setHour:0 Minute:30];
    [self performSelector:@selector(showOnlyTime) withObject:nil afterDelay:0.5];
}

- (void)showOnlyTime
{
    [_hourScrollView setLabelHidden:YES];
    [_minuScrollView setLabelHidden:YES];
}

- (void)updateTime
{
    NSInteger h = _hour;
    if( _hour > 12 )
        h = _hour-12;
    
    _hourScrollView.currentIndex = h;
    _hourLabel.text = [NSString stringWithFormat:@"%02d", (int)(h==0?12:h)];
    
    _minuScrollView.currentIndex = _minute;
    _minuLabel.text = [NSString stringWithFormat:@"%02d", (int)_minute];
    
    [self updateAMPM];
}

- (void)updateAMPM
{
    BOOL isPM = NO;
    
    if( _hour >= 12 )
        isPM = YES;
    
    if( isPM )
    {
        CGRect rPM = [self rectOfAM];
        CGRect rAM = [self rectOfAM]; rAM.origin.y-=rAM.size.height;
        
        [UIView animateWithDuration:0.4 animations:^{
            _pmLabel.frame = rPM;
            _amLabel.frame = rAM;
            
            _pmLabel.alpha = 1;
            _amLabel.alpha = 0;
        }];
    }
    else
    {
        CGRect rAM = [self rectOfAM];
        CGRect rPM = [self rectOfAM]; rPM.origin.y+=rPM.size.height;
        
        [UIView animateWithDuration:0.4 animations:^{
            _amLabel.frame = rAM;
            _pmLabel.frame = rPM;
            
            _amLabel.alpha = 1;
            _pmLabel.alpha = 0;
        }];
    }
}

- (CGRect)rectOfAM
{
    CGSize s = [self bounds].size;
    return CGRectMake(s.width * 2 / 3, 0, s.width / 3, s.height);
}

#pragma mark - InfiniteScrollViewDelegate
- (void)InfiniteScrollView:(InfiniteScrollView *)scrollView didSelectedIndex:(NSInteger)idx
{
    NSInteger num = idx + (scrollView.isStartingAtZero?0:1);
    if( scrollView == _hourScrollView )
    {
        _hourLabel.text = [NSString stringWithFormat:@"%02d", (int)num];

        if( num == 11 )
        {
            if( _hour == 0 || _hour == 22 )
                _hour = 23;
            else
                _hour = 11;
            
            [self updateAMPM];
        }
        else if( num == 12 )
        {
            if( _hour == 23 || _hour == 1 )
                _hour = 0;
            else
                _hour = 12;
            
            [self updateAMPM];
        }
        else
        {
            if( _hour >= 12 )
                _hour = 12 + num;
            else
                _hour = num;
        }
    }
    else if( scrollView == _minuScrollView )
    {
        _minute = num;
        _minuLabel.text = [NSString stringWithFormat:@"%02d", (int)num];
    }
}

- (void)InfiniteScrollViewDidStartScrolling:(InfiniteScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeDidSelect) object:nil];
    [_hourScrollView setLabelHidden:NO];
    [_minuScrollView setLabelHidden:NO];
    
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(timePickerDidStartSelection:)] )
        [_delegate timePickerDidStartSelection:self];
}

- (void)InfiniteScrollViewDidEndScrolling:(InfiniteScrollView *)scrollView
{
    if( !_hourScrollView.isScrolling && !_minuScrollView.isScrolling )
        [self performSelector:@selector(timeDidSelect) withObject:nil afterDelay:1.5];
}

- (void)timeDidSelect
{
    [self showOnlyTime];
    
    if( _delegate!=nil && [_delegate respondsToSelector:@selector(timePickerDidSelectTime:)] )
        [_delegate timePickerDidSelectTime:self];
    
    NSLog(@"Time: %d:%d", (int)_hour, (int)_minute);
}

#pragma mark - Public
- (void)setHour:(NSInteger)h Minute:(NSInteger)m
{
    _hour = h;
    _minute = m;
    
    [self updateTime];
}

@end
