//
//  CHGridViewController.h
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/22/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <UIKit/UIKit.h>
#import "CHGridView.h"

@interface CHGridViewController : UIViewController <CHGridViewDataSource,CHGridViewDelegate> {
	CHGridView			*myGridView;
	NSMutableArray		*images;
}

@end
