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

@interface CHGridView()
- (int)maxNumberOfReusableTiles;
- (void)loadVisibleSectionTitlesForSectionRange:(CHSectionRange)range;
- (void)loadVisibleTilesForIndexPathRange:(CHGridIndexRange)range;
- (void)loadVisibleTileForIndexPath:(CHGridIndexPath)indexPath;
- (void)reuseHiddenTiles;
- (void)removeSectionTitleNotInRange:(CHSectionRange)range;
- (void)removeAllSubviews;
- (NSMutableArray *)tilesForSection:(int)section;
- (NSMutableArray *)tilesFromIndex:(int)startIndex toIndex:(int)endIndex inSection:(int)section;
- (CHSectionTitleView *)sectionTitleViewForSection:(int)section;
- (void)calculateSectionTitleOffset;
@end

@implementation CHGridView
@synthesize dynamicallyResizeTilesToFillSpace, allowsSelection, padding, rowHeight, perLine, sectionTitleHeight, shadowOffset, shadowColor, shadowBlur;

- (id)init{
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){
		if(visibleTiles == nil)
			visibleTiles = [[NSMutableArray alloc] init];
		
		if(visibleSectionTitles == nil)
			visibleSectionTitles = [[NSMutableArray alloc] init];
			
		if(reusableTiles == nil)
			reusableTiles = [[NSMutableArray alloc] init];
		
		if(layout == nil)
			layout = [[CHGridLayout alloc] init];
		
		if(sectionCounts == nil)
			sectionCounts = [[NSMutableArray alloc] init];
		
		sections = 1;
		
		allowsSelection = YES;
		dynamicallyResizeTilesToFillSpace = NO;
		padding = CGSizeMake(10.0, 10.0);
		rowHeight = 100.0;
		perLine = 5;
		sectionTitleHeight = 25.0;
		
		preLoadMultiplier = 2.0;
		
		shadowOffset = CGSizeMake(0, 0);
		shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.5] retain];
		shadowBlur = 0.0;
		
		[self setBackgroundColor:[UIColor whiteColor]];
	}
	return self;
}

- (void)dealloc {
	[shadowColor release];
	[sectionCounts release];
	[layout release];
	[reusableTiles release];
	[visibleSectionTitles release];
	[visibleTiles release];
    [super dealloc];
}

#pragma mark loading methods

- (int)maxNumberOfReusableTiles{
	return ceil((self.bounds.size.height / rowHeight) * perLine);
}

- (void)loadVisibleSectionTitlesForSectionRange:(CHSectionRange)range{
	CGRect b = self.bounds;
	if(sections <= 1) return;
	
	int i;
	for (i = range.start; i <= range.end; i++) {
		BOOL found = NO;
		
		for(CHSectionTitleView *title in visibleSectionTitles){
			if(title.section == i) found = YES;
		}
		
		if(!found){
			CGFloat yCoordinate = [layout yCoordinateForTitleOfSection:i];
			
			CHSectionTitleView *sectionTitle = nil;
			
			if([gridDelegate respondsToSelector:@selector(titleViewForHeaderOfSection:inGridView:)]){
				sectionTitle = [gridDelegate titleViewForHeaderOfSection:i inGridView:self];
				[sectionTitle setFrame:CGRectMake(0, yCoordinate, b.size.width, sectionTitleHeight)];
			}else{
				sectionTitle = [[CHSectionTitleView alloc] initWithFrame:CGRectMake(0, yCoordinate, b.size.width, sectionTitleHeight)];
				if([dataSource respondsToSelector:@selector(titleForHeaderOfSection:inGridView:)])
					[sectionTitle setTitle:[dataSource titleForHeaderOfSection:i inGridView:self]];
			}
			
			[sectionTitle setYCoordinate:yCoordinate];
			[sectionTitle setSection:i];
			[sectionTitle setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
			
			if(self.dragging || self.tracking || self.decelerating)
				[self insertSubview:sectionTitle atIndex:self.subviews.count - 1];
			else
				[self insertSubview:sectionTitle atIndex:self.subviews.count];
				
			[visibleSectionTitles addObject:sectionTitle];
			[sectionTitle release];
		}
	}
	
	[self removeSectionTitleNotInRange:range];
}

- (void)loadVisibleTilesForIndexPathRange:(CHGridIndexRange)range{
	int i, j, ground, ceiling;
	for(i = range.start.section; i < range.end.section + 1; i++){
		ground = 0;
		ceiling = 0;
		
		if(i == range.start.section) ground = range.start.tileIndex;
		else ground = 0;
		if(i == range.end.section) ceiling = range.end.tileIndex + 1;
		else ceiling = [[sectionCounts objectAtIndex:i] intValue];
		
		for(j = ground; j < ceiling; j++){
			[self loadVisibleTileForIndexPath:CHGridIndexPathMake(i, j)];
		}
	}
	
	[self reuseHiddenTiles];
}

- (void)loadVisibleTileForIndexPath:(CHGridIndexPath)indexPath{
	for(CHTileView *tile in visibleTiles){
		if(tile.indexPath.section == indexPath.section && tile.indexPath.tileIndex == indexPath.tileIndex){
			return;
		}
	}
	
	CHTileView *tile = [dataSource tileForIndexPath:indexPath inGridView:self];
	[tile setIndexPath:indexPath];
	
	CGRect rect = [layout tileFrameForIndexPath:indexPath];
	
	if([gridDelegate respondsToSelector:@selector(sizeForTileAtIndex:inGridView:)] && !dynamicallyResizeTilesToFillSpace){
		CGSize size = [gridDelegate sizeForTileAtIndex:indexPath inGridView:self];
		CGRect centeredRect = [layout centerRect:CGRectMake(0, 0, size.width, size.height) inLargerRect:rect roundUp:NO];
		centeredRect.origin.y += rect.origin.y;
		centeredRect.origin.x += rect.origin.x;
		[tile setFrame:centeredRect];
		[tile setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
	}else{
		[tile setFrame:rect];
		[tile setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)];
	}
	
	[tile setBackgroundColor:self.backgroundColor];
	
	[tile setShadowOffset:shadowOffset];
	[tile setShadowColor:shadowColor];
	[tile setShadowBlur:shadowBlur];
	
	[self addSubview:tile];
	[self sendSubviewToBack:tile];
	[visibleTiles addObject:tile];
}

- (void)reuseHiddenTiles{
	NSMutableArray *toReuse = [NSMutableArray array];
	
	CGRect b = self.bounds;
	CGFloat contentOffsetY = self.contentOffset.y;
	float pixelMargin = rowHeight * 2;
	int maxReusable = [self maxNumberOfReusableTiles];
	
	for(CHTileView *tile in visibleTiles){
		if(tile.frame.origin.y + tile.frame.size.height < (contentOffsetY - pixelMargin) || tile.frame.origin.y > (contentOffsetY + b.size.height + pixelMargin)){
			[toReuse addObject:tile];
			if(reusableTiles.count < maxReusable) [reusableTiles addObject:tile];
		}
	}
	
	[toReuse makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[visibleTiles removeObjectsInArray:toReuse];
}

- (void)removeSectionTitleNotInRange:(CHSectionRange)range{
	NSMutableArray *toDelete = [[NSMutableArray alloc] init];
	
	for (CHSectionTitleView *title in visibleSectionTitles) {
		if(title.section < range.start || title.section > range.end){
			[toDelete addObject:title];
		}
	}
	
	[toDelete makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[visibleSectionTitles removeObjectsInArray:toDelete];
	[toDelete release];
}

- (void)reloadData{
	if(dataSource == nil) return;
	
	[self removeAllSubviews];
	[visibleTiles removeAllObjects];
	[visibleSectionTitles removeAllObjects];
	
	CGRect b = [self bounds];
	
	if([dataSource respondsToSelector:@selector(numberOfSectionsInGridView:)]){
		sections = [dataSource numberOfSectionsInGridView:self];
		if(sections == 0) sections = 1;
	}else {
		sections = 1;
	}
	
	[sectionCounts removeAllObjects];
	
	[layout setGridWidth:b.size.width];
	[layout setPadding:padding];
	[layout setPerLine:perLine];
	[layout setRowHeight:rowHeight];
	[layout setPreLoadMultiplier:preLoadMultiplier];
	[layout setSectionTitleHeight:sectionTitleHeight];
	[layout setDynamicallyResizeTilesToFillSpace:dynamicallyResizeTilesToFillSpace];
	
	[layout setSections:sections];
	int i;
	for(i = 0; i < sections; i++){
		int numberInSection = [dataSource numberOfTilesInSection:i GridView:self];
		[sectionCounts addObject:[NSNumber numberWithInt:numberInSection]];
		[layout setNumberOfTiles:numberInSection ForSectionIndex:i];
	}

	[layout updateLayout];
	[self setNeedsLayout];
}

- (CHTileView *)dequeueReusableTileWithIdentifier:(NSString *)identifier{
	for(CHTileView *tile in reusableTiles){
		CHTileView *foundTile = nil;
		if([[tile reuseIdentifier] isEqualToString:identifier]) foundTile = [tile retain];
		[reusableTiles removeObject:tile];
		return foundTile;
	}
	return nil;
}

#pragma mark view and layout methods

- (void)layoutSubviews{
	if(dataSource == nil) return;
	
	CGRect b = [self bounds];
	[self setContentSize:CGSizeMake(b.size.width, [layout contentHeight])];
	float contentOffsetY = self.contentOffset.y;
	
	CHGridIndexRange tileRange = [layout rangeOfVisibleIndexesForContentOffset:contentOffsetY andHeight:b.size.height];
	[self loadVisibleTilesForIndexPathRange:tileRange];
	
	//if([gridDelegate respondsToSelector:@selector(visibleTilesChangedTo:)]) [gridDelegate visibleTilesChangedTo:visibleTiles.count];
	
	if(sections > 1){
		CHSectionRange sectionRange = [layout sectionRangeForContentOffset:contentOffsetY andHeight:b.size.height];
		[self loadVisibleSectionTitlesForSectionRange:sectionRange];
		[self calculateSectionTitleOffset];
	}
}

- (void)removeAllSubviews{
	[visibleTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[visibleSectionTitles makeObjectsPerformSelector:@selector(removeFromSuperview)];
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

- (CHSectionTitleView *)sectionTitleViewForSection:(int)section{
	CHSectionTitleView *titleView = nil;
	
	for(CHSectionTitleView *sectionView in visibleSectionTitles){
		if([sectionView section] == section) titleView = sectionView;
	}
	
	return titleView;
}

#pragma mark indexPath accessor methods

- (CHGridIndexPath)indexPathForPoint:(CGPoint)point{
	return CHGridIndexPathMake(0, 0);
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

- (void)deselecSelectedTile{
	if(selectedTile){
		[self deselectTileAtIndexPath:selectedTile.indexPath];
		selectedTile = nil;
	}
}

#pragma mark property setters

- (void)setDataSource:(id<CHGridViewDataSource>)d{
	dataSource = d;
}

- (void)setGridDelegate:(id<CHGridViewDelegate>)d{
	gridDelegate = d;
}

- (void)setDynamicallyResizeTilesToFillSpace:(BOOL)dynamically{
	dynamicallyResizeTilesToFillSpace = dynamically;
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
		if([gridDelegate respondsToSelector:@selector(selectedTileAtIndexPath:inGridView:)])
			[gridDelegate selectedTileAtIndexPath:[selectedTile indexPath] inGridView:self];
	}
}

#pragma mark section title view offset

- (void)calculateSectionTitleOffset{
	float offset = self.contentOffset.y;
	
	for(CHSectionTitleView *title in visibleSectionTitles){
		CGRect f = [title frame];
		
		if(title.yCoordinate <= offset && offset > 0){
			f.origin.y = offset;
			if(offset <= 0) f.origin.y = title.yCoordinate;
			
			CHSectionTitleView *sectionTwo = [self sectionTitleViewForSection:title.section + 1];
			if(sectionTwo != nil){
				if((offset + sectionTwo.frame.size.height) >= sectionTwo.yCoordinate){
					f.origin.y = sectionTwo.yCoordinate - sectionTwo.frame.size.height;
				}
			}
		}else{
			f.origin.y = title.yCoordinate;
		}
		
		if(f.origin.y <= offset) [title setOpaque:NO];
		else [title setOpaque:YES];
		
		[title setFrame:f];
	}
}

@end
