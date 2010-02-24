//
//  CHImageTileView.h
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <Foundation/Foundation.h>
#import "CHTileView.h"

@interface CHImageTileView : CHTileView {
	UIImage			*image;
	BOOL			scalesImageToFit;
}

@property (nonatomic, retain) UIImage		*image;
@property (nonatomic) BOOL					scalesImageToFit; // don't use this EVER

@end
