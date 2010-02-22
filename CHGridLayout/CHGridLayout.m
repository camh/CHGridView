//
//  CHGridLayout.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHGridLayout.h"
#import "CHGridLayoutTile.h"
#import "CHGridLayoutSection.h"

@implementation CHGridLayout
@synthesize gridWidth, contentHeight, padding, perLine, rowHeight, sectionTitleHeight, dynamicallyResizeTilesToFillSpace;

- (id)init{
	if(self = [super init]){
		if(_index == nil)
			_index = [[NSMutableArray alloc] init];
		
		if(_sectionTitles == nil)
			_sectionTitles = [[NSMutableArray alloc] init];
		
		contentHeight = 0.0;
		rowHeight = 0.0;
	}
	return self;
}

- (void)dealloc{
	[_sectionTitles release];
	[_index release];
	[super dealloc];
}

#pragma mark setters

- (void)setSections:(int)sections{
	[self clearData];
	
	int i;
	for(i = 0; i < sections; i++){
		NSMutableArray *section = [NSMutableArray array];
		CHGridLayoutSection *section2 = [[CHGridLayoutSection alloc] initWithSection:i];
		[_index addObject:section];
		[_sectionTitles addObject:section2];
		[section2 release];
	}
}

- (void)setNumberOfTiles:(int)tiles ForSectionIndex:(int)section{
	if(section < 0 || section >= _index.count) return;
	
	int i;
	for(i = 0; i < tiles; i++){
		CHGridLayoutTile *tile = [[CHGridLayoutTile alloc] initWithIndexPath:CHGridIndexPathMake(section, i)];
		[[_index objectAtIndex:section] addObject:tile];
		[tile release];
	}
}

#pragma mark data & layout

- (void)clearData{
	[_index removeAllObjects];
	[_sectionTitles removeAllObjects];
	contentHeight = 0.0;
}

- (void)updateLayout{
	int sections = _index.count;
	
	float perLineFloat = perLine;
	
	int u;
	for(u = 0; u < _index.count; u++){
		int numberOfTilesInSection = [[_index objectAtIndex:u] count];
		contentHeight += ceil(numberOfTilesInSection / perLineFloat) * rowHeight;
	}
	if(sections > 1) contentHeight += (sectionTitleHeight * sections) + ((sections - 1) * padding.height);
	contentHeight += padding.height;
	
	int i;
	for(i = 0; i < _index.count; i++){
		CHGridLayoutSection *section = [_sectionTitles objectAtIndex:i];
		CHGridLayoutSection *previousSection = nil;
		if(i > 0) previousSection = [_sectionTitles objectAtIndex:(i - 1)];
		NSMutableArray *tilesForSection = [_index objectAtIndex:i];
		
		if(sections > 1){
			float previousY = 0.0;
			if(previousSection != nil) previousY = previousSection.yCoordinate;
			int numberOfTilesInPreviousSection = 0;
			if(i > 0) numberOfTilesInPreviousSection = [[_index objectAtIndex:(i - 1)] count];
			float sectionYPadding = 0.0f;
			if(i > 0) sectionYPadding = padding.height + sectionTitleHeight;
			
			[section setYCoordinate:ceil(numberOfTilesInPreviousSection / perLineFloat) * rowHeight + sectionYPadding + previousY];
		}else{
			section = nil;
		}
		
		for(CHGridLayoutTile *tile in tilesForSection){
			float y = 0.0;
			if(section != nil) y = section.yCoordinate + sectionTitleHeight;
			
			float rowXPadding = (padding.width * perLineFloat) + padding.width;
			float row = floor(tile.indexPath.tileIndex / perLine);
			int rowIndex = tile.indexPath.tileIndex - (row * perLine);
			
			float width = ceil((gridWidth - rowXPadding) / perLine);
			float height = rowHeight - padding.height;
			
			[tile setRect:CGRectMake(padding.width + (rowIndex * width) + (rowIndex * padding.width), row * rowHeight + y + padding.height, width, height)];
		}
	}
}

#pragma mark layout accessors

- (int)sectionIndexForContentOffset:(CGFloat)offset{
	int sectionIndex = 0;
	
	int i;
	for(i = 0; i < _sectionTitles.count; i++){
		CHGridLayoutSection *section = [_sectionTitles objectAtIndex:i];
		if(section.yCoordinate <= offset && offset > 0){
			sectionIndex = i;
		}
	}
	return sectionIndex;
}

- (CGFloat)yCoordinateForTitleOfSection:(int)section{
	return [[_sectionTitles objectAtIndex:section] yCoordinate];
}

- (CHSectionRange)sectionRangeForContentOffset:(CGFloat)offset andHeight:(CGFloat)height{
	int start = 0;
	int end = 0;
	
	BOOL firstRun = YES;
	float pixelMargin = rowHeight * 2;
	int currentSection = [self sectionIndexForContentOffset:offset];
	
	int i;
	for(i = currentSection; i < _sectionTitles.count; i++){
		if(firstRun){
			start = i;
			firstRun = NO;
		}
		
		CHGridLayoutSection *section = [_sectionTitles objectAtIndex:i];
		
		if(section.yCoordinate > (offset - pixelMargin) && section.yCoordinate <  (offset + height + pixelMargin)){
			end = section.section;
		}

		if(start > end) end = start;
	}
	
	return CHSectionRangeMake(start, end);
}

- (CGRect)tileFrameForIndexPath:(CHGridIndexPath)indexPath{
	NSMutableArray *sectionTiles = [_index objectAtIndex:indexPath.section];
	if(indexPath.tileIndex >= sectionTiles.count) return CGRectZero;
	else return [[sectionTiles objectAtIndex:indexPath.tileIndex] rect];
}

- (CHGridIndexRange)rangeOfVisibleIndexesForContentOffset:(CGFloat)offset andHeight:(CGFloat)height{
	float pixelMargin = rowHeight * 2;
	BOOL first = NO;
	
	CHGridIndexRange indexRange = {CHGridIndexPathMake(0, 0),CHGridIndexPathMake(0, 0)};
	
	for(NSMutableArray *sectionArray in _index){
		for(CHGridLayoutTile *tile in sectionArray){
			if(tile.rect.origin.y < (height + offset + pixelMargin) && tile.rect.origin.y >= offset - pixelMargin){
				if(first == NO){
					indexRange.start = [tile indexPath];
					first = YES;
				}
				indexRange.end = [tile indexPath];
			}
		}
	}
	
	first = NO;
	
	return indexRange;
}

#pragma mark convenience layout methods

- (CGRect)centerRect:(CGRect)smallerRect inLargerRect:(CGRect)largerRect roundUp:(BOOL)roundUp{
	if (roundUp)
		return CGRectMake(ceil((largerRect.size.width - smallerRect.size.width) / 2), ceil((largerRect.size.height - smallerRect.size.height) / 2), smallerRect.size.width, smallerRect.size.height);
	
	return CGRectMake(floor((largerRect.size.width - smallerRect.size.width) / 2), floor((largerRect.size.height - smallerRect.size.height) / 2), smallerRect.size.width, smallerRect.size.height);
}

@end
