//
//  CHTileView.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHTileView.h"

@implementation CHTileView
@synthesize indexPath, selected, highlighted, contentBackgroundColor, reuseIdentifier, shadowOffset, shadowColor, shadowBlur;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseId{
	if(self = [super initWithFrame:frame]){
		indexPath = CHGridIndexPathMake(0, 0);
		selected = NO;
		reuseIdentifier = [reuseId copy];
		
		contentBackgroundColor = [[UIColor whiteColor] retain];
		
		shadowOffset = CGSizeMake(0, 0);
		shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.5] retain];
		shadowBlur = 0.0;
		
		[self setBackgroundColor:[UIColor whiteColor]];
		[self setOpaque:YES];
		[self setContentMode:UIViewContentModeRedraw];
	}
	return self;
}

- (void)dealloc {
	[shadowColor release];
	[reuseIdentifier release];
    [super dealloc];
}

- (void)setSelected:(BOOL)s{
	selected = s;
	[self setNeedsDisplay];
}

- (void)unselect{
	[self setSelected:NO];
}

- (void)setIndexPath:(CHGridIndexPath)index{
	indexPath = index;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGSize newShadowOffset = shadowOffset;
	
	CGRect contentRect = CGRectInset(rect, shadowBlur, shadowBlur);
	if(newShadowOffset.height < 0) contentRect.size.height -= fabsf(newShadowOffset.height);
	if(newShadowOffset.width < 0) contentRect.size.width -= fabsf(newShadowOffset.width);
	if(newShadowOffset.height > 0) contentRect.origin.y += fabsf(newShadowOffset.height);
	if(newShadowOffset.width > 0) contentRect.size.width -= fabsf(newShadowOffset.width);
	
	//draw shadow
	
	if(newShadowOffset.height > 0 || newShadowOffset.width > 0 || shadowBlur > 0){
		if(!selected){
			CGContextSaveGState(c);
			CGContextSetShadowWithColor(c, newShadowOffset, shadowBlur, [shadowColor CGColor]);
			[contentBackgroundColor set];
			CGContextFillRect(c, contentRect);
			CGContextRestoreGState(c);
		}else {
			contentRect.origin.y += 1.0;
		}
	}
	
	CGContextSaveGState(c);
	CGContextClipToRect(c, contentRect);
	[self drawContentRect:contentRect];
	CGContextRestoreGState(c);
	
	if(selected){
		[[UIColor colorWithWhite:0.0 alpha:0.3] set];
		CGContextFillRect(c, contentRect);
	}
}

- (void)drawContentRect:(CGRect)rect{
	// subclass me and override this method
}

- (NSString *)description{
	return [NSString stringWithFormat:@"CHTileView, section = %i tileIndex = %i x = %f y = %f w = %f h = %f", indexPath.section, indexPath.tileIndex, self.frame.origin.x, self.frame.origin.x, self.frame.size.width, self.frame.size.height];
}

@end