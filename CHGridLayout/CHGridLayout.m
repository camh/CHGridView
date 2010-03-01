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
#include <sys/types.h>  
#include <sys/sysctl.h> 

#define SLOW_DEVICE_PRELOAD 2.0f

@implementation CHGridLayout
@synthesize index, justTiles, gridWidth, contentHeight, padding, perLine, preLoadMultiplier, rowHeight, sectionTitleHeight;

- (id)init{
	if(self = [super init]){
		if(index == nil)
			index = [[NSMutableArray alloc] init];
		
		if(sectionTitles == nil)
			sectionTitles = [[NSMutableArray alloc] init];
		
		if(justTiles == nil)
			justTiles = [[NSMutableArray alloc] init];
		
		preLoadMultiplier = 5.0f;
		
		contentHeight = 0.0f;
		rowHeight = 0.0f;
	}
	return self;
}

- (void)dealloc{
	[justTiles release];
	[sectionTitles release];
	[index release];
	[super dealloc];
}

#pragma mark setters

- (void)setRowHeight:(CGFloat)f{
	rowHeight = f;
	pixelMargin = f * preLoadMultiplier;
}

- (void)setPreLoadMultiplier:(float)f{
	preLoadMultiplier = f;
	
	size_t size;  
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);  
	char *machine = malloc(size);  
	sysctlbyname("hw.machine", machine, &size, NULL, 0);  
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];  
	free(machine);
	
	if([platform isEqualToString:@"iPhone1,1"]) preLoadMultiplier = SLOW_DEVICE_PRELOAD;
	if([platform isEqualToString:@"iPhone1,2"]) preLoadMultiplier = SLOW_DEVICE_PRELOAD;
	if([platform isEqualToString:@"iPod1,1"]) preLoadMultiplier = SLOW_DEVICE_PRELOAD;
}

- (void)setSections:(int)sections{
	[self clearData];
	
	int i;
	for(i = 0; i < sections; i++){
		NSMutableArray *section = [NSMutableArray array];
		CHGridLayoutSection *section2 = [[CHGridLayoutSection alloc] initWithSection:i];
		[index addObject:section];
		[sectionTitles addObject:section2];
		[section2 release];
	}
}

- (void)setNumberOfTiles:(int)tiles ForSectionIndex:(int)section{
	if(section < 0 || section >= index.count) return;
	
	int i;
	for(i = 0; i < tiles; i++){
		CHGridLayoutTile *tile = [[CHGridLayoutTile alloc] initWithIndexPath:CHGridIndexPathMake(section, i)];
		[[index objectAtIndex:section] addObject:tile];
		[justTiles addObject:tile];
		[tile release];
	}
}

#pragma mark data & layout

- (void)clearData{
	[index removeAllObjects];
	[justTiles removeAllObjects];
	[sectionTitles removeAllObjects];
	contentHeight = 0.0f;
}

- (void)updateLayout{
	int sections = index.count;
	
	float perLineFloat = perLine;
	
	for(NSMutableArray *array in index){
		int numberOfTilesInSection = [array count];
		contentHeight += ceilf(numberOfTilesInSection / perLineFloat) * rowHeight;
	}
	
	if(sections > 1) contentHeight += (sectionTitleHeight * sections) + ((sections - 1) * padding.height);
	contentHeight += padding.height;
	
	int i;
	for(i = 0; i < index.count; i++){
		CHGridLayoutSection *section = [sectionTitles objectAtIndex:i];
		CHGridLayoutSection *previousSection = nil;
		if(i > 0) previousSection = [sectionTitles objectAtIndex:(i - 1)];
		NSMutableArray *tilesForSection = [index objectAtIndex:i];
		
		if(sections > 1){
			float previousY = 0.0;
			if(previousSection != nil) previousY = previousSection.yCoordinate;
			int numberOfTilesInPreviousSection = 0;
			if(i > 0) numberOfTilesInPreviousSection = [[index objectAtIndex:(i - 1)] count];
			float sectionYPadding = 0.0f;
			if(i > 0) sectionYPadding = padding.height + sectionTitleHeight;
			
			[section setYCoordinate:ceilf(numberOfTilesInPreviousSection / perLineFloat) * rowHeight + sectionYPadding + previousY];
		}else{
			section = nil;
		}
		
		for(CHGridLayoutTile *tile in tilesForSection){
			float y = 0.0;
			if(section != nil) y = section.yCoordinate + sectionTitleHeight;
			
			float rowXPadding = (padding.width * perLineFloat) + padding.width;
			float row = floorf(tile.indexPath.tileIndex / perLine);
			int rowIndex = tile.indexPath.tileIndex - (row * perLine);
			
			float width = ceilf((gridWidth - rowXPadding) / perLine);
			float height = rowHeight - padding.height;
			
			[tile setRect:CGRectMake(padding.width + (rowIndex * width) + (rowIndex * padding.width), row * rowHeight + y + padding.height, width, height)];
		}
	}
}

#pragma mark layout accessors

- (int)sectionIndexForContentOffset:(CGFloat)offset{
	int sectionIndex = 0;
	
	for(CHGridLayoutSection *section in sectionTitles){
		if(section.yCoordinate <= offset && offset > 0){
			sectionIndex = section.section;
		}
	}
	
	return sectionIndex;
}

- (CGFloat)yCoordinateForTitleOfSection:(int)section{
	return [[sectionTitles objectAtIndex:section] yCoordinate];
}

- (CHSectionRange)sectionRangeForContentOffset:(CGFloat)offset andHeight:(CGFloat)height{
	int start = 0;
	int end = 0;
	
	BOOL firstRun = YES;
	int currentSection = [self sectionIndexForContentOffset:offset];
	
	float firstY = (offset - pixelMargin);
	float secondY = (offset + height + pixelMargin);
	
	for(CHGridLayoutSection *section in sectionTitles){
		int s = section.section;
		float sy = section.yCoordinate;
		
		if(firstRun && s >= currentSection){
			start = s;
			firstRun = NO;
		}
		
		if(sy > firstY && sy <  secondY){
			end = s;
		}
		
		if(start > end) end = start;
	}
	
	return CHSectionRangeMake(start, end);
}

- (CHGridIndexPath)closestIndexPathToContentOffsetY:(CGFloat)offset{
	CHGridLayoutTile *closestTile = nil;
	
	for(NSMutableArray *section in index){
		for(CHGridLayoutTile *tile in section){
			if(tile.rect.origin.y > offset){
				if(closestTile == nil){
					closestTile = tile;
				}else if(tile.rect.origin.y < closestTile.rect.origin.y && closestTile.rect.origin.y < offset){
					closestTile = tile;
				}
			}
		}
	}
	
	if(closestTile != nil){
		return [closestTile indexPath];
	}
	return CHGridIndexPathMake(0, 0);
}

- (CGRect)tileFrameForIndexPath:(CHGridIndexPath)indexPath{
	NSMutableArray *sectionTiles = [index objectAtIndex:indexPath.section];
	return [[sectionTiles objectAtIndex:indexPath.tileIndex] rect];
}

- (CHGridIndexRange)rangeOfVisibleIndexesForContentOffset:(CGFloat)offset andHeight:(CGFloat)height{
	BOOL first = NO;
	CHGridIndexRange indexRange = {CHGridIndexPathMake(0, 0),CHGridIndexPathMake(0, 0)};
	
	float firstY = (height + offset + pixelMargin);
	float secondY = offset - pixelMargin;
	
	for(NSMutableArray *sectionArray in index){
		for(CHGridLayoutTile *tile in sectionArray){
			if(tile.rect.origin.y < firstY && tile.rect.origin.y + tile.rect.size.height >= secondY){
				if(!first){
					indexRange.start = [tile indexPath];
					first = YES;
				}
				indexRange.end = [tile indexPath];
			}
		}
	}
	
	return indexRange;
}

#pragma mark convenience layout methods

- (CGRect)centerRect:(CGRect)smallerRect inLargerRect:(CGRect)largerRect roundUp:(BOOL)roundUp{
	if (roundUp)
		return CGRectMake(ceilf((largerRect.size.width - smallerRect.size.width) / 2), ceilf((largerRect.size.height - smallerRect.size.height) / 2), smallerRect.size.width, smallerRect.size.height);
	
	return CGRectMake(floorf((largerRect.size.width - smallerRect.size.width) / 2), floorf((largerRect.size.height - smallerRect.size.height) / 2), smallerRect.size.width, smallerRect.size.height);
}

@end
