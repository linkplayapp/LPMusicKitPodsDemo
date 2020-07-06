//  category: devicelist
//
//  MJRefreshHeaderView.m
//  weibo
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  下拉刷新

//#import "AmazonMusicMethod.h"

#define kPullToRefresh @"devicelist_Drag_to_update"
#define kReleaseToRefresh @"devicelist_Release_to_update"
#define kRefreshing @"devicelist_Loading___"

#define kTimeKey @"MJRefreshHeaderView"

#import "MJRefreshHeaderView.h"

@interface MJRefreshHeaderView()
// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@end

@implementation MJRefreshHeaderView

+ (id)header
{
    return [[MJRefreshHeaderView alloc] init];
}

#pragma mark - UIScrollView相关
#pragma mark 重写设置ScrollView
- (void)setScrollView:(UIScrollView *)scrollView
{
    [super setScrollView:scrollView];
    
    // 设置边框
    self.frame = CGRectMake(0, -kViewHeight, scrollView.frame.size.width, kViewHeight);
    
    // 加载时间
    _lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:kTimeKey];
    
    // 设置时间
    [self updateTimeLabel];
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;
    
    // 归档
    [[NSUserDefaults standardUserDefaults] setObject:_lastUpdateTime forKey:kTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
    if (!_lastUpdateTime) return;
    
    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
#ifdef VARO_TARGET
    formatter.dateFormat = @"MM/dd/yyyy";
#else
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat =[NSString stringWithFormat:@"HH:mm"];
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
#endif

    NSString *time = [formatter stringFromDate:_lastUpdateTime];
    
    // 3.显示日期

#ifdef VARO_TARGET
   _lastUpdateTimeLabel.text = [NSString stringWithFormat:@"%@：%@",LOCALSTRING(@"devicelist_Last_update"),time];
#else
    if ([cmp1 day] == [cmp2 day])
    {
        _lastUpdateTimeLabel.text = [NSString stringWithFormat:@"%@:%@ %@",@"devicelist_Last_update",@"devicelist_Today",time];
    }
    else
    {
        _lastUpdateTimeLabel.text = [NSString stringWithFormat:@"%@：%@",@"devicelist_Last_update",time];
    }
#endif
    
    
}

#pragma mark 设置状态
- (void)setState:(RefreshState)state
{
    if (_state == state) return;
    
    [super setState:state];
    
    // 保存旧状态
    RefreshState oldState = _state;
    
	switch (_state = state) {
		case RefreshStatePulling:
        {
            _statusLabel.text = kReleaseToRefresh;
            
            [UIView animateWithDuration:0.2 animations:^{
                _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                UIEdgeInsets inset = _scrollView.contentInset;
                inset.top = 0;
                _scrollView.contentInset = inset;
            }];
			break;
        }
            
		case RefreshStateNormal:
        {
			_statusLabel.text = kPullToRefresh;
            
            // 刷新完毕
            if (oldState == RefreshStateRefreshing) {
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];
#ifdef NeedAudio
                AudioServicesPlaySystemSound(_endRefreshId);
#endif     
            }
            [UIView animateWithDuration:0.2 animations:^{
                _arrowImage.transform = CGAffineTransformIdentity;
                UIEdgeInsets inset = _scrollView.contentInset;
                inset.top = 0;
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
                inset.top = kViewHeight;
                _scrollView.contentInset = inset;
                // 2.设置滚动位置
                _scrollView.contentOffset = CGPointMake(0, -kViewHeight);
            }];
			break;
        }
	}
}

#pragma mark - 在父类中用得上
// 合理的Y值
- (CGFloat)validY
{
    return 0;
}

// view的类型
- (int)viewType
{
    return RefreshViewTypeHeader;
}
@end
