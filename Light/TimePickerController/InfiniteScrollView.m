//
//  InfiniteScrollView.m
//  Zen Sleep
//
//  Created by Ditriol Wei on 13/3/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import "InfiniteScrollView.h"

#define LABEL_HEIGHT        70

@interface InfiniteScrollView () <UIScrollViewDelegate> {
    CGFloat labelHeight;
}
@property (strong, nonatomic) UIView * labelContainerView;
@property (strong, nonatomic) NSMutableArray * visibleLabels;
@end

@implementation InfiniteScrollView

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
    labelHeight = self.frame.size.height * 2 / 3;
    
    self.contentSize = CGSizeMake(self.frame.size.width, 5000);
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    _labelContainerView.userInteractionEnabled = NO;
    _labelContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_labelContainerView];

    _currentIndex = 0;
}

- (void)setNumberOfLabel:(NSInteger)num startAtZero:(BOOL)isZero
{
    self.visibleLabels = [NSMutableArray array];
    self.isStartingAtZero = isZero;
    
    for( int i = (isZero?0:1) ; i < (isZero?0:1)+num ; i++ )
    {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, i*labelHeight, self.contentSize.width, labelHeight )];
//        label.font = [UIFont fontWithName:@"Gotham Thin" size:20];
        [label setFont:[UIFont systemFontOfSize:20]];
        label.text = [NSString stringWithFormat:@"%02d", i];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0;
        
        [self.labelContainerView addSubview:label];
        
        [self.visibleLabels addObject:label];
    }
}

- (void)setLabelHidden:(BOOL)hidden
{
    NSInteger nCnt = [self.visibleLabels count];
    NSInteger dnIndex = (_currentIndex+1)%nCnt;
    NSInteger upIndex = (_currentIndex-1+nCnt)%nCnt;
    
//    [self.visibleLabels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        UILabel *label = (UILabel *)obj;
//        if( idx == _currentIndex )
//            label.alpha = 0;
//        else if( idx==dnIndex || idx==upIndex )
//        {
//            [UIView animateWithDuration:0.4 animations:^{
//                label.alpha = hidden?0:0.7;
//            }];
//        }
//        else
//            label.alpha = hidden?0:0.7;
//    }];
    
    [self.visibleLabels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = (UILabel *)obj;
        if( idx == _currentIndex )
            label.alpha = 0;
        else if( idx==dnIndex || idx==upIndex )
        {
            [UIView animateWithDuration:0.4 animations:^{
                label.alpha = hidden?0:0.7;
            }];
        }
        else
            label.alpha = hidden?0:0.7;
    }];
}

- (void)setCurrentIndex:(NSInteger)index
{
    if( _isStartingAtZero )
        _currentIndex = index;
    else
    {
        NSInteger nCnt = [self.visibleLabels count];
        _currentIndex = (index-1+nCnt)%nCnt;
    }
    
    [self rearrangeIfNecessary];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    [self refreshCurrentIndex];
    [self rearrangeIfNecessary];
}

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentHeight = [self contentSize].height;
    CGFloat centerOffsetY = (contentHeight - [self bounds].size.height) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);
    
    if( distanceFromCenter > contentHeight/4 )
    {
        NSLog(@"recenterIfNecessary");
        
        self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
        
        NSInteger nCnt = [self.visibleLabels count];
        NSInteger nIndex = ((_currentIndex - nCnt/2) + nCnt) % nCnt;
        CGPoint center;
        center.x = [self contentSize].width/2;
        center.y = (centerOffsetY+[self bounds].size.height/2) - (nCnt/2)*labelHeight;
        // move content by the same amount so it appears to stay still
        for( int i = 0 ; i < nCnt; i++ )
        {
            UILabel * label = [self.visibleLabels objectAtIndex:(nIndex+i)%nCnt];
            label.center = center;
            center.y += labelHeight;
        }
    }
}

- (void)refreshCurrentIndex
{
    CGPoint currentOffset = [self contentOffset];
    CGPoint currentOffsetCenter = CGPointMake(currentOffset.x, currentOffset.y+[self bounds].size.height/2);
    NSInteger nCnt = [self.visibleLabels count];
    NSInteger index = _currentIndex;
    for( int i = 0 ; i < nCnt ; i++ )
    {
        UILabel * label = [self.visibleLabels objectAtIndex:(_currentIndex+i)%nCnt];
        if( CGRectContainsPoint(label.frame, currentOffsetCenter) )
        {
            index = (_currentIndex+i)%nCnt;
            CGFloat ratio = fabs(label.center.y - currentOffsetCenter.y)/labelHeight * 2;
            label.alpha = ratio*0.7;
//            label.font = [UIFont fontWithName:@"Gotham Thin" size:70-50*ratio];
            [label setFont:[UIFont systemFontOfSize:70-50*ratio]];
        }
        else
        {
            label.alpha = 0.7;
//            label.font = [UIFont fontWithName:@"Gotham Thin" size:20];
            [label setFont:[UIFont systemFontOfSize:20]];
        }
    }

    if( _currentIndex != index )
    {
        _currentIndex = index;

        if( _infiniteScrollViewDelegate!=nil && [_infiniteScrollViewDelegate respondsToSelector:@selector(InfiniteScrollView:didSelectedIndex:)] )
            [_infiniteScrollViewDelegate InfiniteScrollView:self didSelectedIndex:_currentIndex];
    }
}

- (void)rearrangeIfNecessary
{
    NSInteger nCnt = [self.visibleLabels count];
    if( _currentIndex < nCnt )
    {
        UILabel * centerLabel = [self.visibleLabels objectAtIndex:_currentIndex];
        CGPoint centerLabelPos = centerLabel.center;
        for( int i = 1 ; i < nCnt ; i++ )
        {
            if( i < nCnt/2 )
            {
                UILabel * label = [self.visibleLabels objectAtIndex:(_currentIndex+i)%nCnt];
                CGPoint center = CGPointMake(centerLabelPos.x, centerLabelPos.y+i*labelHeight);
                if( !CGRectContainsPoint(label.frame, center) )
                    label.center = center;
            }
            else
            {
                UILabel * label = [self.visibleLabels objectAtIndex:(_currentIndex-(i-nCnt/2)+nCnt)%nCnt];
                CGPoint center = CGPointMake(centerLabelPos.x, centerLabelPos.y-(i-nCnt/2)*labelHeight);
                if( !CGRectContainsPoint(label.frame, center) )
                    label.center = center;
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    if( _infiniteScrollViewDelegate!=nil && [_infiniteScrollViewDelegate respondsToSelector:@selector(InfiniteScrollViewDidStartScrolling:)] )
        [_infiniteScrollViewDelegate InfiniteScrollViewDidStartScrolling:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( !decelerate )
        [self scrollingFinished];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinished];
}

- (void)scrollingFinished
{
    if( _currentIndex < [self.visibleLabels count] )
    {
        CGPoint offset = [self contentOffset];
        UILabel * label = [self.visibleLabels objectAtIndex:_currentIndex];
        [self setContentOffset:CGPointMake(offset.x, label.center.y-[self bounds].size.height/2) animated:YES];
    }
    
    self.isScrolling = NO;
    if( _infiniteScrollViewDelegate!=nil && [_infiniteScrollViewDelegate respondsToSelector:@selector(InfiniteScrollViewDidEndScrolling:)] )
        [_infiniteScrollViewDelegate InfiniteScrollViewDidEndScrolling:self];
}

@end
