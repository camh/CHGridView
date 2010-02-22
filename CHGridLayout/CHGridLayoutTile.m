//
//  CHGridLayoutTile.m
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHGridLayoutTile.h"

@implementation CHGridLayoutTile
@synthesize indexPath, rect;

- (id)initWithIndexPath:(CHGridIndexPath)index{
	if(self = [super init]){
		indexPath = index;
		
		rect = CGRectZero;
	}
	return self;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"%@, indexPath section = %i tileIndex = %i, x = %f y = %f w = %f h = %f", [super description], indexPath.section, indexPath.tileIndex, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (void)dealloc{
	[super dealloc];
}

@end
