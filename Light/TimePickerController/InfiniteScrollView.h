//
//  InfiniteScrollView.h
//  Zen Sleep
//
//  Created by Ditriol Wei on 13/3/16.
//  Copyright © 2016 Zen Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfiniteScrollViewDelegate;
@interface InfiniteScrollView : UIScrollView

@property (assign, nonatomic) id<InfiniteScrollViewDelegate> infiniteScrollViewDelegate;

@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) BOOL isStartingAtZero;
@property (assign, nonatomic) BOOL isScrolling;

- (void)setNumberOfLabel:(NSInteger)num startAtZero:(BOOL)isZero;
- (void)setLabelHidden:(BOOL)hidden;
@end


@protocol InfiniteScrollViewDelegate <NSObject>
@optional
- (void)InfiniteScrollView:(InfiniteScrollView *)scrollView didSelectedIndex:(NSInteger)idx;

- (void)InfiniteScrollViewDidStartScrolling:(InfiniteScrollView *)scrollView;
- (void)InfiniteScrollViewDidEndScrolling:(InfiniteScrollView *)scrollView;

@end