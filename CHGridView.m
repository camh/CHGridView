//
//  CHGridView.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHGridView.h"
#import "CHGridLayoutTile.h"

@interface CHGridView()
- (void)loadVisibleSectionTitlesForSectionRange:(CHSectionRange)range;
- (void)loadVisibleTileForIndexPath:(CHGridIndexPath)indexPath withRect:(CGRect)r;
- (void)reuseHiddenTiles;
- (void)removeSectionTitleNotInRange:(CHSectionRange)range;
- (void)removeAllSubviews;
- (NSMutableArray *)tilesForSection:(int)section;
- (NSMutableArray *)tilesFromIndex:(int)startIndex toIndex:(int)endIndex inSection:(int)section;
- (CHSectionHeaderView *)sectionHeaderViewForSection:(int)section;
- (void)calculateSectionTitleOffset;
@end

@implementation CHGridView
@synthesize dataSource, centerTilesInGrid, allowsSelection, padding, preLoadMultiplier, rowHeight, perLine, sectionTitleHeight;

- (id)init{
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){
		if(visibleTiles == nil)
			visibleTiles = [[NSMutableArray alloc] init];
		
		if(visibleSectionHeaders == nil)
			visibleSectionHeaders = [[NSMutableArray alloc] init];
			
		if(reusableTiles == nil)
			reusableTiles = [[NSMutableArray alloc] init];
		
		if(layout == nil)
			layout = [[CHGridLayout alloc] init];
		
		if(sectionCounts == nil)
			sectionCounts = [[NSMutableArray alloc] init];
		
		sections = 1;
		
		allowsSelection = YES;
		centerTilesInGrid = NO;
		padding = CGSizeMake(10.0f, 10.0f);
		rowHeight = 100.0f;
		perLine = 5;
		sectionTitleHeight = 25.0f;
		
		preLoadMultiplier = 5.0f;
		
		[self setBackgroundColor:[UIColor whiteColor]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reuseHiddenTiles) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	[sectionCounts release];
	[layout release];
	[reusableTiles release];
	[visibleSectionHeaders release];
	[visibleTiles release];
    [super dealloc];
}

#pragma mark loading methods

- (void)loadVisibleSectionTitlesForSectionRange:(CHSectionRange)range{
	CGRect b = self.bounds;
	if(sections <= 1) return;
	
	int i;
	for (i = range.start; i <= range.end; i++) {
		BOOL found = NO;
		
		for(CHSectionHeaderView *header in visibleSectionHeaders){
			if(header.section == i) found = YES;
		}
		
		if(!found){
			CGFloat yCoordinate = [layout yCoordinateForTitleOfSection:i];
			
			CHSectionHeaderView *sectionHeader = nil;
			
			if([[self delegate] respondsToSelector:@selector(titleViewForHeaderOfSection:inGridView:)]){
				sectionHeader = [[self delegate] titleViewForHeaderOfSection:i inGridView:self];
				[sectionHeader setFrame:CGRectMake(b.origin.x, yCoordinate, b.size.width, sectionTitleHeight)];
			}else{
				sectionHeader = [[CHSectionHeaderView alloc] initWithFrame:CGRectMake(b.origin.x, yCoordinate, b.size.width, sectionTitleHeight)];
				if([dataSource respondsToSelector:@selector(titleForHeaderOfSection:inGridView:)])
					[sectionHeader setTitle:[dataSource titleForHeaderOfSection:i inGridView:self]];
			}
			
			[sectionHeader setYCoordinate:yCoordinate];
			[sectionHeader setSection:i];
			[sectionHeader setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
			
			if(self.dragging || self.decelerating)
				[self insertSubview:sectionHeader atIndex:self.subviews.count - 1];
			else
				[self insertSubview:sectionHeader atIndex:self.subviews.count];
				
			[visibleSectionHeaders addObject:sectionHeader];
			[sectionHeader release];
		}
	}
	
	[self removeSectionTitleNotInRange:range];
}

- (void)loadVisibleTileForIndexPath:(CHGridIndexPath)indexPath withRect:(CGRect)r{
	for(CHTileView *tile in visibleTiles){
		CHGridIndexPath tileIndex = tile.indexPath;
		if(tileIndex.section == indexPath.section && tileIndex.tileIndex == indexPath.tileIndex){
			return;
		}
	}
	
	CHTileView *tile = [dataSource tileForIndexPath:indexPath inGridView:self];
	
	[tile setIndexPath:indexPath];
	[tile setSelected:NO];

	if([[self delegate] respondsToSelector:@selector(sizeForTileAtIndex:inGridView:)] && centerTilesInGrid){
		CGSize size = [[self delegate] sizeForTileAtIndex:indexPath inGridView:self];
		CGRect centeredRect = [layout centerRect:CGRectMake(0.0f, 0.0f, size.width, size.height) inLargerRect:r roundUp:NO];
		centeredRect.origin.y += r.origin.y;
		centeredRect.origin.x += r.origin.x;
		[tile setFrame:centeredRect];
		[tile setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
	}else{
		[tile setFrame:r];
		[tile setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)];
	}
	
	[tile setBackgroundColor:self.backgroundColor];
	
	[self insertSubview:tile atIndex:0];
	[visibleTiles addObject:tile];
}

- (void)reuseHiddenTiles{
	NSMutableArray *toReuse = [[NSMutableArray alloc] init];
	
	CGRect b = self.bounds;
	CGFloat contentOffsetY = self.contentOffset.y;
	float pixelMargin = rowHeight * ([layout preLoadMultiplier]);
	
	CGFloat firstY = (b.size.height + contentOffsetY + pixelMargin);
	CGFloat secondY = contentOffsetY - pixelMargin;
	
	for(CHTileView *tile in visibleTiles){
		CGRect r = tile.frame;
		if(r.origin.y > firstY || r.origin.y + r.size.height < secondY){
			[toReuse addObject:tile];
			if(reusableTiles.count < maxReusable) [reusableTiles addObject:tile];
		}
	}
	
	[visibleTiles removeObjectsInArray:toReuse];
	[toReuse release];
}

- (void)removeSectionTitleNotInRange:(CHSectionRange)range{
	NSMutableArray *toDelete = [NSMutableArray array];
	
	for (CHSectionHeaderView *header in visibleSectionHeaders) {
		int s = header.section;
		if(s < range.start || s > range.end){
			[toDelete addObject:header];
		}
	}
	
	[toDelete makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[visibleSectionHeaders removeObjectsInArray:toDelete];
}

- (void)reloadData{
	[self reloadDataAndLayoutUpdateNeeded:YES];
}

- (void)reloadDataAndLayoutUpdateNeeded:(BOOL)layoutNeeded{
	if(dataSource == nil) return;
	
	[self removeAllSubviews];
	[visibleTiles removeAllObjects];
	[visibleSectionHeaders removeAllObjects];
	
	CGRect b = [self bounds];
	
	if([dataSource respondsToSelector:@selector(numberOfSectionsInGridView:)]){
		sections = [dataSource numberOfSectionsInGridView:self];
		if(sections == 0) sections = 1;
	}else {
		sections = 1;
	}
	
	[sectionCounts removeAllObjects];
	
	if(layoutNeeded){
		[layout setGridWidth:b.size.width];
		[layout setPadding:padding];
		[layout setPerLine:perLine];
		[layout setPreLoadMultiplier:preLoadMultiplier];
		[layout setRowHeight:rowHeight];
		[layout setSectionTitleHeight:sectionTitleHeight];
	
		[layout setSections:sections];
		int i;
		for(i = 0; i < sections; i++){
			int numberInSection = [dataSource numberOfTilesInSection:i GridView:self];
			[sectionCounts addObject:[NSNumber numberWithInt:numberInSection]];
			[layout setNumberOfTiles:numberInSection ForSectionIndex:i];
		}
	
		[layout updateLayout];
	}
		
	[self setNeedsLayout];
	
	maxReusable = ceilf((self.bounds.size.height / rowHeight) * perLine) * 2;
	
	if([layout contentHeight] > b.size.height)
		[self setContentSize:CGSizeMake(b.size.width, [layout contentHeight])];
	else
		[self setContentSize:CGSizeMake(b.size.width, b.size.height + 1.0)];
}

- (CHTileView *)dequeueReusableTileWithIdentifier:(NSString *)identifier{
	for(CHTileView *tile in reusableTiles){
		if([[tile reuseIdentifier] isEqualToString:identifier]){
			[[tile retain] autorelease];
			[reusableTiles removeObject:tile];
			return tile;
		}
	}
	return nil;
}

#pragma mark view and layout methods

- (void)layoutSubviews{
	if(dataSource == nil) return;
	
	CGRect b = [self bounds];
	
	[self reuseHiddenTiles];
	
	CGFloat	contentOffsetY = self.contentOffset.y;
	CGFloat pixelMargin = rowHeight * [layout preLoadMultiplier];
	CGFloat firstY = (b.size.height + contentOffsetY + pixelMargin);
	CGFloat secondY = contentOffsetY - pixelMargin;

	BOOL hasSections = (sections > 1);
	
	if(hasSections){
		CHSectionRange sectionRange = [layout sectionRangeForContentOffset:contentOffsetY andHeight:b.size.height];
		[self loadVisibleSectionTitlesForSectionRange:sectionRange];
		[self calculateSectionTitleOffset];
		
	}
	
	for(CHGridLayoutTile *tile in [layout justTiles]){
		CGRect r = [tile rect];
		if(r.origin.y < firstY && r.origin.y + r.size.height > secondY){
			[self loadVisibleTileForIndexPath:tile.indexPath withRect:r];
		}
	}
	
	//if([[self delegate] respondsToSelector:@selector(visibleTilesChangedTo:)]) [[self delegate] visibleTilesChangedTo:visibleTiles.count];
}

- (void)removeAllSubviews{
	[visibleTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[visibleSectionHeaders makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[reusableTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark tiles accessor methods

- (CHTileView *)tileForIndexPath:(CHGridIndexPath)indexPath{
	CHTileView *foundTile = nil;
	
	for(CHTileView *tile in visibleTiles){
		if(tile.indexPath.section == indexPath.section && tile.indexPath.tileIndex == indexPath.tileIndex)
			foundTile = tile;
	}
	
	return foundTile;
}

- (NSMutableArray *)tilesForSection:(int)section{
	NSMutableArray *array = [NSMutableArray array];
	
	for(CHTileView *tile in visibleTiles){
		if(tile.indexPath.section == section){
			[array addObject:tile];
		}
	}
	
	if(array.count > 0) return array;
	return nil;
}

- (NSMutableArray *)tilesFromIndex:(int)startIndex toIndex:(int)endIndex inSection:(int)section{
	NSMutableArray *array = [NSMutableArray array];
	
	for(CHTileView *tile in visibleTiles){
		if(tile.indexPath.section == section && tile.indexPath.tileIndex >= startIndex && tile.indexPath.tileIndex <= endIndex){
			[array addObject:tile];
		}
	}
	
	if(array.count > 0) return array;
	return nil;
}

#pragma mark section title accessor methods

- (CHSectionHeaderView *)sectionHeaderViewForSection:(int)section{
	CHSectionHeaderView *headerView = nil;
	
	for(CHSectionHeaderView *header in visibleSectionHeaders){
		if([headerView section] == section) headerView = header;
	}
	
	return headerView;
}

#pragma mark indexPath accessor methods

- (CHGridIndexPath)indexPathForPoint:(CGPoint)point{
	return CHGridIndexPathMake(0, 0);
}

#pragma mark tile scrolling methods

- (void)scrollToTileAtIndexPath:(CHGridIndexPath)indexPath animated:(BOOL)animated{
	CGRect r = [layout tileFrameForIndexPath:indexPath];
	[self scrollRectToVisible:r animated:animated];
}

#pragma mark selection methods

- (void)deselectTileAtIndexPath:(CHGridIndexPath)indexPath{
	for(CHTileView *tile in visibleTiles){
		if(tile.indexPath.section == indexPath.section && tile.indexPath.tileIndex == indexPath.tileIndex){
			[tile setSelected:NO];
			selectedTile = nil;
		}
	}
}

- (void)deselectSelectedTile{
	if(selectedTile){
		[self deselectTileAtIndexPath:selectedTile.indexPath];
		selectedTile = nil;
	}
}

#pragma mark property setters and getters

- (id<CHGridViewDelegate>)delegate {
	return (id<CHGridViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<UIScrollViewDelegate,CHGridViewDelegate>)d{
	[super setDelegate:d];
}

- (void)setDataSource:(id<CHGridViewDataSource>)d{
	dataSource = d;
}

- (void)setCenterTilesInGrid:(BOOL)b{
	centerTilesInGrid = b;
	[self setNeedsLayout];
}

- (void)setAllowsSelection:(BOOL)allows{
	allowsSelection = allows;
}

#pragma mark touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self];

	UIView *view = [self hitTest:location withEvent:event];
	
	if([view isKindOfClass:[CHTileView class]] && allowsSelection){
		if(selectedTile)
			[self deselectTileAtIndexPath:selectedTile.indexPath];
		
		selectedTile = (CHTileView *)view;
		[selectedTile setSelected:YES];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesMoved:touches withEvent:event];

	if(self.dragging || self.tracking || self.decelerating && allowsSelection){
		if(selectedTile != nil){
			[selectedTile setSelected:NO];
			selectedTile = nil;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self];
	
	UIView *view = [self hitTest:location withEvent:event];
	
	if(selectedTile != nil && [selectedTile isEqual:view] && allowsSelection){
		if([[self delegate] respondsToSelector:@selector(selectedTileAtIndexPath:inGridView:)])
			[[self delegate] selectedTileAtIndexPath:[selectedTile indexPath] inGridView:self];
	}
}

#pragma mark section title view offset

- (void)calculateSectionTitleOffset{
	float offset = self.contentOffset.y;
	
	for(CHSectionHeaderView *header in visibleSectionHeaders){
		CGRect f = [header frame];
		float sectionY = [header yCoordinate];
		
		if(sectionY <= offset && offset > 0.0f){
			f.origin.y = offset;
			if(offset <= 0.0f) f.origin.y = sectionY;
			
			CHSectionHeaderView *sectionTwo = [self sectionHeaderViewForSection:header.section + 1];
			if(sectionTwo != nil){
				CGFloat sectionTwoHeight = sectionTwo.frame.size.height;
				CGFloat	sectionTwoY = sectionTwo.yCoordinate;
				if((offset + sectionTwoHeight) >= sectionTwoY){
					f.origin.y = sectionTwoY - sectionTwoHeight;
				}
			}
		}else{
			f.origin.y = sectionY;
		}
		
		if(f.origin.y <= offset) [header setOpaque:NO];
		else [header setOpaque:YES];
		
		[header setFrame:f];
	}
}

@end
