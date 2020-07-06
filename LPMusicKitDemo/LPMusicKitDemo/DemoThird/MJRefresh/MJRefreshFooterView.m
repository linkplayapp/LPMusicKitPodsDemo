//  category: devicelist
//
//  MJRefreshFooterView.m
//  weibo
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  上拉加载更多

//#import "AmazonMusicMethod.h"

#define kPullToRefresh @"devicelist_Drag_to_update"
#define kReleaseToRefresh @"devicelist_Release_to_update"
#define kRefreshing @"devicelist_Loading___"

#import "MJRefreshFooterView.h"

@implementation MJRefreshFooterView

+ (id)footer
{
    return [[MJRefreshFooterView alloc] init];
}

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        // 移除刷新时间
		[_lastUpdateTimeLabel removeFromSuperview];
        _lastUpdateTimeLabel = nil;
    }
    return self;
}

#pragma mark - UIScrollView相关
#pragma mark 重写设置ScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    // 1.移除以前的监听器
    @try {
        [_scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
    }
    @catch (NSException *exception) {
        
    }
    // 2.监听contentSize
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    // 3.父类的方法
    [super setScrollView:scrollView];
    
    // 4.重新调整frame
    [self adjustFrame];
}

- (void)removeFromSuperview
{
    @try {
        [self.superview removeObserver:self forKeyPath:@"contentSize" context:nil];
    }
    @catch (NSException *exception) {
        
    }

    [super removeFromSuperview];
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([@"contentSize" isEqualToString:keyPath]) {
        [self adjustFrame];
    }
}

#pragma mark 重写调整frame
- (void)adjustFrame
{
    // 内容的高度
    CGFloat contentHeight = _scrollView.contentSize.height;
    // 表格的高度
    CGFloat scrollHeight = _scrollView.frame.size.height;
    CGFloat y = MAX(contentHeight, scrollHeight);
    // 设置边框
    self.frame = CGRectMake(0, y-(50), _scrollView.frame.size.width, kViewHeight);
    
    // 挪动标签的位置
    CGPoint center = _statusLabel.center;
    center.y = _arrowImage.center.y;
    _statusLabel.center = center;
}

#pragma mark - 状态相关
#pragma mark 设置状态
- (void)setState:(RefreshState)state
{
    if (_state == state) return;
    
    [super setState:state];
    
	switch (_state = state)
    {
		case RefreshStatePulling:
        {
            _statusLabel.text = kReleaseToRefresh;
            
            [UIView animateWithDuration:0.2 animations:^{
                _arrowImage.transform = CGAffineTransformIdentity;
                UIEdgeInsets inset = _scrollView.contentInset;
                inset.bottom = 0;
                _scrollView.contentInset = inset;
            }];
			break;
        }
            
		case RefreshStateNormal:
        {
			_statusLabel.text = kPullToRefresh;
            
            [UIView animateWithDuration:0.2 animations:^{
                _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                UIEdgeInsets inset = _scrollView.contentInset;
                inset.bottom = 0;
                _scrollView.contentInset = inset;
            }];
			break;
        }
            
        case RefreshStateRefreshing:
        {
            _statusLabel.text = kRefreshing;
            
            [UIView animateWithDuration:0.2 animations:^{
                // 1.顶部多出65的滚动范围
                UIEdgeInsets inset = _scrollView.contentInset;
                inset.bottom = self.frame.origin.y - _scrollView.contentSize.height +kViewHeight;
                _scrollView.contentInset = inset;
                
                // 2.设置滚动位置
                _scrollView.contentOffset = CGPointMake(0, self.validY + kViewHeight);
            }];
			break;
        }
	}
}

#pragma mark - 在父类中用得上
// 合理的Y值
- (CGFloat)validY
{
    return MAX(_scrollView.contentSize.height, _scrollView.frame.size.height) - _scrollView.frame.size.height;
}

// view的类型
- (int)viewType
{
    return RefreshViewTypeFooter;
}
@end
