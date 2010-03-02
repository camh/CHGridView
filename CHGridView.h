//
//  CHGridView.h
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <UIKit/UIKit.h>
#import "CHTileView.h"
#import "CHSectionHeaderView.h"
#import "CHGridLayout.h"

@class CHGridView;
@class CHTileView;

// data source protocol

@protocol CHGridViewDataSource <NSObject>
	- (int)numberOfTilesInSection:(int)section GridView:(CHGridView *)gridView;
	- (CHTileView *)tileForIndexPath:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView;
@optional
	- (int)numberOfSectionsInGridView:(CHGridView *)gridView;
	- (NSString *)titleForHeaderOfSection:(int)section inGridView:(CHGridView *)gridView;
@end

// delegate protocol

@protocol CHGridViewDelegate <NSObject,UIScrollViewDelegate>
@optional
	- (void)selectedTileAtIndexPath:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView;
	- (void)visibleTilesChangedTo:(int)tiles;
	- (CGSize)sizeForTileAtIndex:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView;
	- (CHSectionHeaderView *)headerViewForSection:(int)section inGridView:(CHGridView *)gridView;
@end

@interface CHGridView : UIScrollView {
	CHGridLayout					*layout;
	
	NSMutableArray					*visibleTiles;
	NSMutableArray					*visibleSectionHeaders;
	NSMutableArray					*reusableTiles;
	
	id<CHGridViewDataSource>		dataSource;
	
	int								sections;
	NSMutableArray					*sectionCounts;
	int								maxReusable;
	
	CHTileView						*selectedTile;
	BOOL							isSlowDevice;

	//settable properties
	BOOL							centerTilesInGrid;
	BOOL							allowsSelection;
	CGSize							padding;
	float							preLoadMultiplier;
	float							rowHeight;
	int								perLine;
	float							sectionTitleHeight;
}

@property (nonatomic, assign) id<CHGridViewDataSource> dataSource;
@property (nonatomic, assign) id<CHGridViewDelegate,UIScrollViewDelegate> delegate;

@property (nonatomic) BOOL						centerTilesInGrid;
@property (nonatomic) BOOL						allowsSelection;
@property (nonatomic) CGSize					padding;
@property (nonatomic) float						preLoadMultiplier;
@property (nonatomic) float						rowHeight;
@property (nonatomic) int						perLine;
@property (nonatomic) float						sectionTitleHeight;

- (void)reloadData;
- (void)reloadDataAndLayoutUpdateNeeded:(BOOL)layoutNeeded;

- (CHTileView *)dequeueReusableTileWithIdentifier:(NSString *)identifier;

- (CHTileView *)tileForIndexPath:(CHGridIndexPath)indexPath;
- (CHGridIndexPath)indexPathForPoint:(CGPoint)point;

- (void)scrollToTileAtIndexPath:(CHGridIndexPath)indexPath animated:(BOOL)animated;
- (void)deselectTileAtIndexPath:(CHGridIndexPath)indexPath;
- (void)deselectSelectedTile;

@end
