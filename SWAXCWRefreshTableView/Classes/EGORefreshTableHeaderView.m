//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

#define APP_LANGUAGE @"Localizable" 
#define TEXT_COLOR	 [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void) initControl:(CGRect)frame ;
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;
@synthesize direction = _direction;

- (id) initWithFrame:(CGRect)frame byDirection:(EGOPullRefreshDirection)direc

{
    
    if ((self = [super initWithFrame:frame])) {
        
        _direction = direc;
    
        
        [self initControl:frame];
        
    }
    
    
    
    return self;
    
}

- (BOOL)isLoading{
    return  _state==EGOOPullRefreshLoading;
}


-(void)initControl:(CGRect)frame{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = TEXT_COLOR;
//    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _lastUpdatedLabel=label;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = TEXT_COLOR;
//    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    CALayer *layer = [CALayer layer];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ){
        layer.frame = CGRectMake(frame.size.width / 2 - 30, frame.size.height - 55.0f, 30.0f, 50.0f);
        if(frame.size.width<320){
            layer.frame = CGRectMake(-5, frame.size.height - 55.0f, 30.0f, 50.0f);
        }
    }else {
       layer.frame = CGRectMake(10.0f, frame.size.height - 55.0f, 30.0f, 55.0f);
    }
 
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (id)[UIImage imageNamed:@"grayArrow.png"].CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        layer.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
    [[self layer] addSublayer:layer];
    _arrowImage=layer;
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ){
        view.frame = CGRectMake(frame.size.width / 2 - 30, frame.size.height - 38.0f, 20.0f, 20.0f);
        if(frame.size.width<320){
            view.frame = CGRectMake(0, frame.size.height - 38.0f, 20.0f, 20.0f);
        }
    }else {
        view.frame = CGRectMake(10.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
    }
    
   
    [self addSubview:view];
    _activityView = view;
    
    
    [self setState:EGOOPullRefreshNormal];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		

		_direction = EGOOPullRefreshUp; //默认上拉刷新
        
    
        [self initControl:frame];
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		_lastUpdatedLabel.text = [NSString stringWithFormat: NSLocalizedStringFromTable(@"上次加载时间: %@",APP_LANGUAGE, @""), [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
    
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
            switch (_direction) {
                    
                case EGOOPullRefreshUp:
                    _statusLabel.text=[self.delegate egoPullRefreshUpPulling]; 
                    
                    break;
                    
                    
                    
                case EGOOPullRefreshDown:
                    _statusLabel.text=[self.delegate egoPullRefreshDownPulling]; 
                    
                    break;
                    
            }  
            
            
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
            
            [self showTitle];
            
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = @"加载中...";
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

-(void)showTitle{
    switch (_direction) {
            
        case EGOOPullRefreshUp:
            _statusLabel.text=[self.delegate egoPullRefreshUpNormal]; 
            
            break;
            
            
            
        case EGOOPullRefreshDown:
            _statusLabel.text=[self.delegate egoPullRefreshDownNormal]; 
            
            break;
            
    }
}

-(void)showLoading:(UIScrollView *)scrollView{
    
    [self setState:EGOOPullRefreshLoading];
    [scrollView setContentOffset:CGPointMake(-0.0f, -60.0f)];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; 
    scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations]; 
    
}


-(void)hiddenLoading:(UIScrollView *)scrollView{       
    [self egoRefreshScrollViewDataSourceDidFinishedLoading:scrollView];  
    
}



#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
        switch (_direction) {
                
            case EGOOPullRefreshUp:
                
                scrollView.contentInset = UIEdgeInsetsMake(0, 0.0f, RefreshViewHight-10, 0.0f);
                
                break;
                
            case EGOOPullRefreshDown:
                
                scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
                
                break;
                
        }
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
        
        switch (_direction) {
                
            case EGOOPullRefreshUp:
                
                if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshViewHight && scrollView.contentOffset.y > 0.0f && !_loading) {
                    
                    [self setState:EGOOPullRefreshNormal];
                    
                } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight &&!_loading) {
                    
                    [self setState:EGOOPullRefreshPulling];
                    
                }
                
                  break;
                
            case EGOOPullRefreshDown:
                
                if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
                    
                    [self setState:EGOOPullRefreshNormal];
                    
                } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
                    
                    [self setState:EGOOPullRefreshPulling];
                    
                }
                
                break;
        }
        
        if (scrollView.contentInset.bottom != 0) {
            
            scrollView.contentInset = UIEdgeInsetsZero;
            
        }
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
        
        switch (_direction) {
                
            case EGOOPullRefreshUp:
                
                if (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHight && !_loading) {
                    
                    
                    
                    if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:direction:)]) {
                        
                        [_delegate egoRefreshTableHeaderDidTriggerRefresh:self direction:_direction];
                        
                    }
                    
                    
                [self setState:EGOOPullRefreshLoading];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
               scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHight-10, 0.0f);
                [UIView commitAnimations];
                
                }
                break;
                    
                case EGOOPullRefreshDown:
                    
                    if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
                        
                        
                        
                        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:direction:)]) {
                            
                            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self direction:_direction];
                            
                        }
                    
                        
                        
                        [self setState:EGOOPullRefreshLoading];
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:0.2];
                       scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
                        [UIView commitAnimations];
                        
                    }
                break;
                
        }
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
    
}
- (void)egoRefreshScrollViewMoreDidFinishedLoading:(UIScrollView *)scrollView {
    
    scrollView.contentOffset=CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y+1);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
    
}



@end
