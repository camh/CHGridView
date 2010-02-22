//
//  CHImageTileView.m
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#include <math.h>.
#import "CHImageTileView.h"

@implementation CHImageTileView
@synthesize image, scalesImageToHeight;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseId{
	if(self = [super initWithFrame:frame reuseIdentifier:reuseId]){
		if(image == nil)
			image = [[UIImage alloc] init];
		
		scalesImageToHeight = NO;
	}
	return self;
}

- (void)setImage:(UIImage *)i{
	[image release];
	image = [i retain];
	[self setNeedsDisplay];
}

- (void)drawContentRect:(CGRect)rect{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGSize imageSize = [image size];
	CGRect b = rect;
	
	float newWidth = 0.0;
	float newHeight = 0.0;
	float leftOffset = 0.0;
	float topOffset = 0.0;
	
	if(scalesImageToHeight){
		float heightDividedByWidth = imageSize.height / imageSize.width;
		float widthDividedByHeight = imageSize.width / imageSize.height;
		
		BOOL isPortrait = (heightDividedByWidth >= 1.0);
		float largerSide = fmax(b.size.height, b.size.width);
		float smallerSide = fmin(b.size.height, b.size.width);
		
		if(isPortrait){
			newWidth = largerSide;
			newHeight = ceil(largerSide * heightDividedByWidth);
			leftOffset = 0.0;
			topOffset = ceil((smallerSide - newHeight) / 2) - b.origin.y;
		} else{
			newWidth = ceil(largerSide * widthDividedByHeight);
			newHeight = largerSide;
			leftOffset = ceil((smallerSide - newWidth) / 2);
			topOffset = 0.0 - b.origin.y;
		}
	}else{
		if(b.size.height > imageSize.height) topOffset = ceil((b.size.height - imageSize.height) / 2) - b.origin.y;
		else topOffset = ceil((b.size.height - imageSize.height) / 2) - b.origin.y;
		
		if(b.size.width > imageSize.width) leftOffset = ceil((b.size.width - imageSize.width) / 2);
		else leftOffset = ceil((b.size.width - imageSize.width) / 2);
		
		newWidth = imageSize.width;
		newHeight = imageSize.height;
	}
	
	CGRect imageRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	
	CGContextSaveGState(c);
	CGContextTranslateCTM(c, 0.0f, b.size.height);
	CGContextScaleCTM(c, 1.0f, -1.0f);
	CGContextDrawImage(c, imageRect, [image CGImage]);
	CGContextRestoreGState(c);
	
	//draw border
	
	CGRect borderRect = CGRectIntersection(rect, imageRect);
	if(borderRect.size.height < rect.size.height) borderRect.size.height = rect.size.height;
	
	CGContextClipToRect(c, borderRect);
	
	CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:1.0 alpha:0.15] CGColor]); //light border
	CGContextStrokeRectWithWidth(c, borderRect, 4.0);
	
	CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.0 alpha:0.4] CGColor]); // dark border
	CGContextStrokeRectWithWidth(c, borderRect, 2.0);
	
	//draw tile index -- used for debugging
	
	/*NSString *title = [NSString stringWithFormat:@"%i",indexPath.tileIndex];
	float textWidth = b.size.width - (15.0 * 2);
	UIFont *f = [UIFont boldSystemFontOfSize:16.0];
	
	[[UIColor whiteColor] set];
	CGContextSetShadow(c, CGSizeMake(0, -1.0), 1.0);
	
	CGSize fontSize = [title sizeWithFont:f forWidth:textWidth lineBreakMode:UILineBreakModeTailTruncation];
	[title drawInRect:CGRectMake(15.0, ceil((b.size.height - fontSize.height) / 2), textWidth, fontSize.height) withFont:f lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];*/
}

@end
