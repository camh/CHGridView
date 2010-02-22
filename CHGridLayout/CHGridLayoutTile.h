//
//  CHGridLayoutTile.h
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <Foundation/Foundation.h>
#import "CHTileView.h"

@interface CHGridLayoutTile : NSObject {
	CHGridIndexPath		indexPath;
	CGRect				rect;
}

- (id)initWithIndexPath:(CHGridIndexPath)index;

@property (nonatomic, readonly) CHGridIndexPath		indexPath;
@property (nonatomic) CGRect						rect;

@end
