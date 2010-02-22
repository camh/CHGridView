//
//  CHTileView.h
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import <UIKit/UIKit.h>

struct CHGridIndexPath {
	int section;
	int tileIndex;
};
typedef struct CHGridIndexPath CHGridIndexPath;

static CHGridIndexPath CHGridIndexPathMake(int section, int tileIndex){
	CHGridIndexPath index; index.section = section; index.tileIndex = tileIndex; return index;
}

@interface CHTileView : UIView {
	NSString			*reuseIdentifier;
	CHGridIndexPath		indexPath;
	CGSize				padding;
	
	BOOL				selected;
	BOOL				highlighted;
	
	CGSize				shadowOffset;
	UIColor				*shadowColor;
	CGFloat				shadowBlur;
}

@property (nonatomic) CHGridIndexPath				indexPath;
@property (nonatomic, readonly, copy) NSString		*reuseIdentifier;

@property (nonatomic) BOOL							selected;
@property (nonatomic) BOOL							highlighted;

@property (nonatomic) CGSize						shadowOffset;
@property (nonatomic, retain) UIColor				*shadowColor;
@property (nonatomic) CGFloat						shadowBlur;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseId;

// sub classes must implement drawContentRect:
- (void)drawContentRect:(CGRect)rect;
- (void)unselect;

@end
