//
//  CHGridLayoutSection.h
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <Foundation/Foundation.h>


@interface CHGridLayoutSection : NSObject {
	int			section;
	CGFloat		yCoordinate;
}

@property (nonatomic, readonly) int		section;
@property (nonatomic) CGFloat			yCoordinate;

- (id)initWithSection:(int)s;

@end
