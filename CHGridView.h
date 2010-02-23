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
#import "CHSectionTitleView.h"
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

@protocol CHGridViewDelegate <NSObject>
@optional
	- (void)selectedTileAtIndexPath:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView;
	- (void)visibleTilesChangedTo:(int)tiles;
	- (CGSize)sizeForTileAtIndex:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView;
	- (CHSectionTitleView *)titleViewForHeaderOfSection:(int)section inGridView:(CHGridView *)gridView;
@end

@interface CHGridView : UIScrollView {
	CHGridLayout					*layout;
	
	NSMutableArray					*visibleTiles;
	NSMutableArray					*visibleSectionTitles;
	NSMutableArray					*reusableTiles;
	
	id<CHGridViewDataSource>		dataSource;
	id<CHGridViewDelegate>			gridDelegate;
	
	int								sections;
	NSMutableArray					*sectionCounts;
	
	CHTileView						*selectedTile;

	//settable properties
	BOOL							dynamicallyResizeTilesToFillSpace;
	BOOL							allowsSelection;
	CGSize							padding;
	float							preLoadMultiplier;
	float							rowHeight;
	int								perLine;
	float							sectionTitleHeight;
	
	CGSize							shadowOffset;
	UIColor							*shadowColor;
	CGFloat							shadowBlur;
}

@property (nonatomic) BOOL						dynamicallyResizeTilesToFillSpace;
@property (nonatomic) BOOL						allowsSelection;
@property (nonatomic) CGSize					padding;
@property (nonatomic) float						preLoadMultiplier;
@property (nonatomic) float						rowHeight;
@property (nonatomic) int						perLine;
@property (nonatomic) float						sectionTitleHeight;

@property (nonatomic) CGSize					shadowOffset;
@property (nonatomic, retain) UIColor			*shadowColor;
@property (nonatomic) CGFloat					shadowBlur;

- (void)setDataSource:(id<CHGridViewDataSource>)d;
- (void)setGridDelegate:(id<CHGridViewDelegate>)d;

- (void)reloadData;

- (CHTileView *)dequeueReusableTileWithIdentifier:(NSString *)identifier;
- (CHTileView *)tileForIndexPath:(CHGridIndexPath)indexPath;
- (CHGridIndexPath)indexPathForPoint:(CGPoint)point;

- (void)deselectTileAtIndexPath:(CHGridIndexPath)indexPath;
- (void)deselecSelectedTile;

@end
