//
//  CWRefreshTableView.h
//  youliao
//
//  Created by hsm on 12-6-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

//pull direction

typedef enum {
    
    CWRefreshTableViewDirectionUp,
    
    CWRefreshTableViewDirectionDown,
    
    CWRefreshTableViewDirectionAll
    
}CWRefreshTableViewDirection;



//pull type

typedef enum CellStatus {
    
	CellStatusShow = 0,
    
	CellStatusHide = 1, 
    
} CellStatus;

typedef enum {
    
    CWRefreshTableViewPullTypeReload,           //重新加载
    
    CWRefreshTableViewPullTypeLoadMore,         //加载更多
    
}CWRefreshTableViewPullType;

@interface UITableViewCell(UITableViewCellExtras)

-(void)setReloadTime:(NSTimeInterval)reloadTime;

-(NSTimeInterval)reloadTime;

-(void)setSection:(NSInteger)section;

-(NSInteger)section;

-(void)setRow:(NSInteger)row;

-(NSInteger)row;

-(void)setStatus:(CellStatus)status;

-(CellStatus)status;

@end


@protocol CWRefreshTableViewDelegate;

@interface CWRefreshTableView : UITableView<EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    
    BOOL                        _reloading;
    
    EGORefreshTableHeaderView  *_headView;
    
    EGORefreshTableHeaderView  *_footerView;
     
    CWRefreshTableViewDirection    _direction;
    
}

@property (nonatomic,assign)  long  totalPage;
@property (nonatomic,assign)  long  currentPage;
@property (nonatomic,assign)  BOOL type;
@property (assign) BOOL isScroll;
@property (assign) float offsetY;

@property (nonatomic, weak) id<CWRefreshTableViewDelegate> pullDelegate;

//方向
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullDirection:(CWRefreshTableViewDirection)cwDirection;
-(id)initWithFrame:(CGRect)frame pullDirection:(CWRefreshTableViewDirection) cwDirection;

-(void)initWithDirection:(CWRefreshTableViewDirection) cwDirection;

//加载完成调用
- (void)showPrepareInfo;
- (void)dataSourceDidFinishedLoading;

- (void)refreshHeadDataSource;
- (void)hiddenHeadDataSource;
- (void)refreshFootDataSource;
- (void)hiddenFootDataSource;

@end
 
@protocol CWRefreshTableViewDelegate <NSObject,UITableViewDelegate,UITableViewDataSource>
@optional

-(void)pullUp;
-(void)pullDown;

//上拉加载数据显示
- (NSString *)pullRefreshUpNormal;

- (NSString *)pullRefreshUpPulling;

//下拉加载数据显示
- (NSString *)pullRefreshDownNormal;

- (NSString *)pullRefreshDownPulling;
 
//重新加载 
-(void)loadTableViewDataSource;

//加载更多
-(void)loadTableViewMoreData;

- (NSString *)dateKey;

//cell即将被回收的时候回调用此方法
-(void)tableView:(UITableView *)tableView willNotDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)tableViewScrollViewDidScroll:(UITableView *)tableView;
 
@end