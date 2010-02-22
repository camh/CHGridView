//
//  CHGridLayoutSection.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHGridLayoutSection.h"

@implementation CHGridLayoutSection
@synthesize section, yCoordinate;

- (id)initWithSection:(int)s{
	if(self = [super init]){
		section = s;
		yCoordinate = 0.0;
	}
	return self;
}

- (void)dealloc{
	[super dealloc];
}

@end
