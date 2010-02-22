//
//  CHImageTileView.h
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <Foundation/Foundation.h>
#import "CHTileView.h"

@interface CHImageTileView : CHTileView {
	UIImage			*image;
	BOOL			scalesImageToHeight;
}

@property (nonatomic, retain) UIImage		*image;
@property (nonatomic) BOOL					scalesImageToHeight; // don't use this EVER

@end
