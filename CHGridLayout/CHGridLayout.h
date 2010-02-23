//
//  CHGridLayout.h
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <Foundation/Foundation.h>
#import "CHTileView.h"

struct CHGridIndexRange {
	CHGridIndexPath start;
	CHGridIndexPath end;
};
typedef struct CHGridIndexRange CHGridIndexRange;

struct CHSectionRange {
	int start;
	int end;
};
typedef struct CHSectionRange CHSectionRange;

static CHSectionRange CHSectionRangeMake(int start, int end){
	CHSectionRange range; range.start = start; range.end = end; return range;
}

//-----------

@interface CHGridLayout : NSObject {
	NSMutableArray		*_index;
	NSMutableArray		*_sectionTitles;
	
	float				gridWidth;
	float				contentHeight;
	CGSize				padding;
	int					perLine;
	float				preLoadMultiplier;
	float				rowHeight;
	float				pixelMargin;
	float				sectionTitleHeight;
	BOOL				dynamicallyResizeTilesToFillSpace; 
}

@property (nonatomic) float					gridWidth;
@property (nonatomic, readonly) CGFloat		contentHeight;
@property (nonatomic) CGSize				padding;
@property (nonatomic) int					perLine;
@property (nonatomic) float					preLoadMultiplier;
@property (nonatomic) float					rowHeight;
@property (nonatomic) float					sectionTitleHeight;
@property (nonatomic) BOOL					dynamicallyResizeTilesToFillSpace;

- (void)setSections:(int)sections;
- (void)setNumberOfTiles:(int)tiles ForSectionIndex:(int)section;
- (void)updateLayout;
- (void)clearData;

- (CGFloat)yCoordinateForTitleOfSection:(int)section;
- (CHSectionRange)sectionRangeForContentOffset:(CGFloat)offset andHeight:(CGFloat)height;
- (CGRect)tileFrameForIndexPath:(CHGridIndexPath)indexPath;
- (CHGridIndexRange)rangeOfVisibleIndexesForContentOffset:(CGFloat)offset andHeight:(CGFloat)height;

- (CGRect)centerRect:(CGRect)smallerRect inLargerRect:(CGRect)largerRect roundUp:(BOOL)roundUp;

@end
