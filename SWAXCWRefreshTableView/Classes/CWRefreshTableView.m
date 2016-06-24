//
//  CWRefreshTableView.m
//  youliao
//
//  Created by hsm on 12-6-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CWRefreshTableView.h"
#import "MessageInterceptor.h"
#import <objc/runtime.h>
#define APP_LANGUAGE @"Localizable" 

static const char *sectionKey="-__sectionKey__-";
static const char *rowKey="-__rowKey__-";
static const char *cellStatusKey="-__cellStatusKey__-";
static const char *reloadTimeKey="-__reloadTimeKey__-";

@implementation UITableViewCell(UITableViewCellExtras)

-(void)setReloadTime:(NSTimeInterval)reloadTime{
    objc_setAssociatedObject(self, reloadTimeKey, [NSNumber numberWithDouble:reloadTime], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSTimeInterval)reloadTime{
    NSNumber *reloadTimeValue= objc_getAssociatedObject(self, reloadTimeKey);
    return [reloadTimeValue doubleValue];
}
-(void)setSection:(NSInteger)section{
    objc_setAssociatedObject(self, sectionKey, [NSNumber numberWithInt:section], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSInteger)section{
    NSNumber *sectionValue= objc_getAssociatedObject(self, sectionKey);
    return [sectionValue intValue];
}
-(void)setRow:(NSInteger)row{
    objc_setAssociatedObject(self, rowKey, [NSNumber numberWithInt:row], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSInteger)row{
    NSNumber *rowValue= objc_getAssociatedObject(self, rowKey);
    return [rowValue intValue];
} 
-(void)setStatus:(CellStatus)statusValue{
    objc_setAssociatedObject(self, cellStatusKey, [NSNumber numberWithInt:statusValue], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(CellStatus)status{
    NSNumber *statusValue=objc_getAssociatedObject(self, cellStatusKey);
    switch ([statusValue intValue]) {
        case  0:
            return CellStatusShow;
            break;
        case  1:
            return CellStatusHide;
            break; 
            
    }
    
    return CellStatusShow;
}

@end


@interface CWRefreshTableView(){
    
    MessageInterceptor * delegateInterceptor;
    
    NSMutableSet *cells;
    
    NSObject *lock;
}

- (void) initControl;
- (void) initPullDownView;
- (void) initPullUpView;
- (void) initPullAllView;
- (void) updatePullViewFrame;
@end



@implementation CWRefreshTableView 

@synthesize pullDelegate;
@synthesize currentPage,totalPage;
@synthesize type;
@synthesize isScroll;

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullDirection:(CWRefreshTableViewDirection) cwDirection {
    if (self = [super initWithFrame:frame style:style]) {
        cells=[[NSMutableSet alloc] init];
//        
        delegateInterceptor = [[MessageInterceptor alloc] init];
        delegateInterceptor.middleMan = self;
        delegateInterceptor.receiver = self.delegate; 
        
        _direction = cwDirection;
        
        type=NO;
        
        [self initControl];
        
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame 

           pullDirection:(CWRefreshTableViewDirection) cwDirection

{
    
    if (self = [super initWithFrame:frame]) {
        cells=[[NSMutableSet alloc] init];
//        
        delegateInterceptor = [[MessageInterceptor alloc] init];
        delegateInterceptor.middleMan = self;
        delegateInterceptor.receiver = self.delegate;
//        super.delegate = (id)delegateInterceptor;
        
        _direction = cwDirection;
        
        type=NO;
        
        [self initControl];
        
    }
    
    return self;
    
}

-(void)initWithDirection:(CWRefreshTableViewDirection) cwDirection

{
        cells=[[NSMutableSet alloc] init];
        //
        delegateInterceptor = [[MessageInterceptor alloc] init];
        delegateInterceptor.middleMan = self;
        delegateInterceptor.receiver = self.delegate;
        //        super.delegate = (id)delegateInterceptor;
        
        _direction = cwDirection;
        
        type=NO;
        
        [self initControl];
    
    
}



#pragma mark private

- (void) initControl

{
    
    switch (_direction) {
            
        case CWRefreshTableViewDirectionUp:
            
            [self initPullUpView];
            
            break;
            
            
            
        case CWRefreshTableViewDirectionDown:
            
            [self initPullDownView];
            
            break;
            
            
            
        case CWRefreshTableViewDirectionAll:
            
            [self initPullAllView];
            
            break;
            
    }
    
}



- (void) initPullDownView

{
    
    CGFloat fWidth = self.frame.size.width;
    
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -60.0, fWidth, 60.0) 
                                       
                                                                          byDirection:EGOOPullRefreshDown];
    
    view.delegate = self;
    
    [self addSubview:view];
    
    [view bringSubviewToFront:self];
    
    view.autoresizingMask = self.autoresizingMask;
    
    _headView = view;
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([pullDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [pullDelegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void) initPullUpView

{
    
    CGFloat fWidth = self.frame.size.width;
    
    CGFloat originY = self.contentSize.height;
    
    CGFloat originX = self.contentOffset.x;
    
    if (originY < self.frame.size.height) {
        
        originY = self.frame.size.height;
        
    }
    
    
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(originX, originY, fWidth, 60)
                                       
                                                                          byDirection:EGOOPullRefreshUp];
     
    
    view.delegate = self;
    
    [self addSubview:view];
    
    [view bringSubviewToFront:self];
    
    view.autoresizingMask = self.autoresizingMask;
    
    _footerView = view; 
    
}

- (void) initPullAllView

{
    
    [self initPullUpView];
    
    [self initPullDownView];
    
}
-(void)reloadData{
    NSLog(@"reloadData currentThread:%@",[NSThread currentThread]);
    for (UITableViewCell *cell in cells) {
        if([pullDelegate respondsToSelector:@selector(tableView:willNotDisplayCell:forRowAtIndexPath:)]){
            [pullDelegate tableView:self willNotDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:cell.row inSection:cell.section]];
        }
    }
    
    [cells removeAllObjects];
    [super reloadData];
}

- (void) updatePullViewFrame

{
    
    if (_headView != nil) {  
        
    }
    
    if (_footerView != nil) {
        
        CGFloat fWidth = self.frame.size.width;
        
        CGFloat originY = self.contentSize.height;
        
        CGFloat originX = self.contentOffset.x;
        
        if (originY < self.frame.size.height) {
            
            originY = self.frame.size.height;
            
        }
        
        if (!CGRectEqualToRect(_footerView.frame, CGRectMake(originX, originY, fWidth, 60))) {
            _footerView.frame = CGRectMake(originX, originY, fWidth, 60);  
        }
    }
    
}
-(void)setPullDelegate:(id<CWRefreshTableViewDelegate>)_pullDelegate{
    pullDelegate=_pullDelegate;
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = _pullDelegate;
        super.delegate = (id)delegateInterceptor;
        super.dataSource = (id)delegateInterceptor;
    } else {
        super.delegate = _pullDelegate;
    }
    [self showPrepareInfo];
}
- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}


#pragma mark -

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 
    
    if(self.offsetY>scrollView.contentOffset.y&&!_reloading&&scrollView.contentOffset.y>0&&scrollView.contentOffset.y<(scrollView.contentSize.height-scrollView.frame.size.height)){
        if([pullDelegate respondsToSelector:@selector(pullDown)]){
            
            [pullDelegate pullDown];
            
        }
    }else if (self.offsetY<scrollView.contentOffset.y&&!_reloading&&scrollView.contentOffset.y>0&&scrollView.contentOffset.y<(scrollView.contentSize.height-scrollView.frame.size.height)){
        if([pullDelegate respondsToSelector:@selector(pullUp)]){
            
            [pullDelegate pullUp];
            
        }
    }
    
    if (scrollView.contentOffset.y < -60.0f){
        if(![_headView isLoading])
            [_headView egoRefreshScrollViewDidScroll:scrollView];   
    }else if (scrollView.contentOffset.y >  60.0f){
        if(![_footerView isLoading])
            [_footerView egoRefreshScrollViewDidScroll:scrollView]; 
    }
    [self updatePullViewFrame];
    
    
    if([pullDelegate respondsToSelector:@selector(tableViewScrollViewDidScroll:)]){
        
        [pullDelegate tableViewScrollViewDidScroll:self];
        
    }
    if ([pullDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [pullDelegate scrollViewDidScroll:self];
    }
    
    
    float scrollStartY = scrollView.contentOffset.y;
    float scrollEndY = scrollView.contentOffset.y+scrollView.frame.size.height;
    
    NSMutableArray *removeCells=[[NSMutableArray alloc] init];
    for (UITableViewCell *cell in cells) {
        float cellStartY=cell.frame.origin.y;
        float cellEndY=cell.frame.origin.y+cell.frame.size.height;
        
        if(cellStartY>scrollEndY||cellEndY<scrollStartY){
//            @synchronized(lock){
                if(cell.status==CellStatusShow){
                    cell.status=CellStatusHide;
                }else{
                    continue;
                }
//            }
            
            [removeCells addObject:cell];
            if([pullDelegate respondsToSelector:@selector(tableView:willNotDisplayCell:forRowAtIndexPath:)]){
                
                [pullDelegate tableView:self willNotDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:cell.row inSection:cell.section]];
                
            }
        }
    }
    for (UITableViewCell *cell in removeCells) {
        [cells removeObject:cell]; 
    }
    
    self.offsetY =scrollView.contentOffset.y;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{ 
    
    cell.section=indexPath.section;
    cell.row=indexPath.row;
    cell.status=CellStatusShow;
    if([cells containsObject:cell]){
        if([pullDelegate respondsToSelector:@selector(tableView:willNotDisplayCell:forRowAtIndexPath:)]){ 
            [pullDelegate tableView:self willNotDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:cell.row inSection:cell.section]]; 
        } 
    }else{
        [cells addObject:cell];
    }
    if([pullDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]){
        [pullDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([pullDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [pullDelegate scrollViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
//    NSLog(@"--scrollViewDidEndDragging:%d",decelerate);
    
    if (scrollView.contentOffset.y < -60.0f) {
        
        [_headView egoRefreshScrollViewDidEndDragging:scrollView];  
        
    }
    
    else if (scrollView.contentOffset.y > 60.0f)
    
    {
        
        [_footerView egoRefreshScrollViewDidEndDragging:scrollView];
        
    }
    if([pullDelegate respondsToSelector:@selector(tableViewScrollViewEnd:withDelerate:)]){
        [pullDelegate tableViewScrollViewEnd:self withDelerate:decelerate];
    }
}

- (void)showPrepareInfo{
    if(_headView){
        [_headView refreshLastUpdatedDate];
        [_headView showTitle];
    }
    if(_footerView){
        [_footerView refreshLastUpdatedDate];
        [_footerView showTitle];
    }
}

-(void)refreshHeadDataSource{
    
    _reloading = YES;
    [_headView showLoading:self];
    if ([self.delegate respondsToSelector:@selector(loadTableViewDataSource)]) {
        [self.delegate performSelector:@selector(loadTableViewDataSource)];
    }
    
}
-(void)hiddenHeadDataSource{
    
    [_headView hiddenLoading:self];
    _reloading = NO; 
}
-(void)refreshFootDataSource{
    
    _reloading = YES;
    [_footerView showLoading:self];
    if ([self.delegate respondsToSelector:@selector(loadTableViewDataSource)]) {
        [self.delegate performSelector:@selector(loadTableViewDataSource)];
    }
    
}
-(void)hiddenFootDataSource{
    
    [_footerView hiddenLoading:self];
    _reloading = NO; 
}



 



#pragma mark -

#pragma mark Data Source Loading / Reloading Methods

- (void) dataSourceDidFinishedLoading

{ 
    self.contentOffset = CGPointMake(self.contentOffset.x,self.contentOffset.y);
    
    _reloading = NO;
    
    if (self.contentOffset.y < -50.0f) {
        [_headView egoRefreshScrollViewDataSourceDidFinishedLoading:self]; 
        
    }else{ 
        [_footerView egoRefreshScrollViewMoreDidFinishedLoading:self];
    }
    
}

#pragma mark -

#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view

                                     direction:(EGOPullRefreshDirection)direc{
    
    
    
         
        if (direc == EGOOPullRefreshUp) {
            
            _reloading = [self CWRefreshTableViewReloadTableViewDataSource:CWRefreshTableViewPullTypeLoadMore];
            
        }
        
        else if (direc == EGOOPullRefreshDown)
        
        {
            
            _reloading = [self CWRefreshTableViewReloadTableViewDataSource:CWRefreshTableViewPullTypeReload];
            
        } 
    
}
- (BOOL) CWRefreshTableViewReloadTableViewDataSource:(CWRefreshTableViewPullType) refreshType{
    
    switch (refreshType) {
        case CWRefreshTableViewPullTypeReload:
            if ([self.delegate respondsToSelector:@selector(loadTableViewDataSource)]) {
                [self.delegate performSelector:@selector(loadTableViewDataSource)];
            }else{ 
                [self performSelector:@selector(dataSourceDidFinishedLoading) withObject:nil afterDelay:1.0f];
            }
            break;
            
        case CWRefreshTableViewPullTypeLoadMore:
            if ([self.delegate respondsToSelector:@selector(loadTableViewMoreData)]) {
                [self.delegate performSelector:@selector(loadTableViewMoreData)];
//                [pullDelegate loadTableViewMoreData];
            }else{
                [self performSelector:@selector(dataSourceDidFinishedLoading) withObject:nil afterDelay:1.0f];
            }
            break;
            
        default:
            break;
    }
    
    
    return YES;
}

- (NSString *)egoPullRefreshUpNormal{
    
    if([pullDelegate respondsToSelector:@selector(pullRefreshUpNormal)]){
        return [pullDelegate pullRefreshUpNormal];
    }
    return NSLocalizedStringFromTable(@"Pull up to more...",APP_LANGUAGE, @"");
}
- (NSString *)egoPullRefreshUpPulling{
    
    if([pullDelegate respondsToSelector:@selector(pullRefreshUpPulling)]){
        return [pullDelegate pullRefreshUpPulling];
    }
    return NSLocalizedStringFromTable(@"Release to more...",APP_LANGUAGE, @"");
    
}
- (NSString *)egoPullRefreshDownNormal{
    if([pullDelegate respondsToSelector:@selector(pullRefreshDownNormal)]){
        return [pullDelegate pullRefreshDownNormal];
    } 
    return  NSLocalizedStringFromTable(@"Pull down to refresh...",APP_LANGUAGE, @"");
}
- (NSString *)egoPullRefreshDownPulling{
    if([pullDelegate respondsToSelector:@selector(pullRefreshDownPulling)]){
        return [pullDelegate pullRefreshDownPulling];
    }
    return NSLocalizedStringFromTable(@"Release to refresh...",APP_LANGUAGE, @"");

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    switch (view.direction) {
            
        case EGOOPullRefreshUp:
//            if(currentPage==totalPage)
//                return YES;
//            else
                return NO;
            break;
        case EGOOPullRefreshDown:
            if(self.type)
                return NO;
            
            else if(currentPage==1)
                return YES;
            else 
                return NO;
            break;
    }
     // should return if data source model is reloading
            return NO;
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    NSDate *_date=[NSDate date]; 
    NSUserDefaults *userDefaults=[NSUserDefaults  standardUserDefaults];
    NSString *key=@"default-key";
    if([pullDelegate respondsToSelector:@selector(dateKey)]){
        key=[pullDelegate dateKey];
    }
    
    id _obj;
    if(view.direction==EGOOPullRefreshUp)
        _obj=[userDefaults objectForKey:[NSString stringWithFormat:@"EGOOPullRefreshUp-%@",key]];
    else 
        _obj=[userDefaults objectForKey:[NSString stringWithFormat:@"EGOOPullRefreshDown-%@",key]];
    
    
    
    
    if(_obj!=nil){
        _date=[NSDate dateWithTimeIntervalSince1970:((NSNumber *)_obj).doubleValue]; 
    }
    
    if(view.direction==EGOOPullRefreshUp)
        [userDefaults setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:[NSString stringWithFormat:@"EGOOPullRefreshUp-%@",key]];
    else  
        [userDefaults setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:[NSString stringWithFormat:@"EGOOPullRefreshDown-%@",key]];
    [userDefaults synchronize];
    
    
    
    return _date;    
}

@end