//
//  CHSectionTitle.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/18/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHSectionTitleView.h"

@implementation CHSectionTitleView
@synthesize section, title, yCoordinate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		if(title == nil)
			title = [[NSString alloc] initWithString:@""];
		
		if(topLine == nil)
			topLine = [[UIView alloc] init];
		
		[topLine setBackgroundColor:[UIColor colorWithHue:0.56 saturation:0.15 brightness:0.52 alpha:1.0]];
		[topLine setOpaque:YES];
		[self addSubview:topLine];
		
		[self setOpaque:YES];
		[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
		[self setContentMode:UIViewContentModeRedraw];
    }
    return self;
}

- (void)dealloc {
	[topLine release];
	[title release];
    [super dealloc];
}

- (void)setSection:(int)s{
	section = s;
	
	if([title isEqualToString:@""]){
		[self setTitle:[NSString stringWithFormat:@"Section %i", section]];
	}
}

- (void)setOpaque:(BOOL)b{
	[super setOpaque:b];
	if(b) [self setBackgroundColor:[UIColor whiteColor]];
	else [self setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews{
	CGRect b = self.bounds;
	[topLine setFrame:CGRectMake(b.origin.x, b.origin.y - 1.0, b.size.width, 1.0)];
}

- (void)drawRect:(CGRect)rect {
	//subclasses should implement drawRect: but must draw title on their own
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGRect b = self.bounds;
	float padding = 10.0;
	float fontHeight = floor(b.size.height * 0.60);
	if(fontHeight > 20.0) fontHeight = 20.0;
	
	//graw gradient
	
	CGGradientRef tabGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	
	float gradientOpacity = 0.85;
	
	CGFloat locations[2] = { 0.0, 1.0 };
	
																			// RGBA values for start and end colors
	CGFloat components[8] = {	0.572, 0.627, 0.670, gradientOpacity,		// Start color
								0.721, 0.756, 0.784, gradientOpacity };		// End color
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	tabGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
	CGContextDrawLinearGradient(c, tabGradient, topCenter, bottomCenter, 0);
	
	CGGradientRelease(tabGradient);
	CGColorSpaceRelease(rgbColorspace);
	
	//draw lines
	
	[[UIColor colorWithWhite:1.0 alpha:0.2] set];
	CGContextFillRect(c, CGRectMake(b.origin.x, b.origin.y, b.size.width, 1.0));
	
	[[UIColor colorWithHue:0.42 saturation:0.07 brightness:0.64 alpha:1.0] set];
	CGContextFillRect(c, CGRectMake(b.origin.x, b.size.height - 1.0, b.size.width, 1.0));
	
	//draw title
	
	float textWidth = b.size.width - (padding * 2);
	UIFont *f = [UIFont boldSystemFontOfSize:fontHeight];
	
	[[UIColor whiteColor] set];
	CGContextSetShadow(c, CGSizeMake(0, -1.0), 1.0);
	
	CGSize fontSize = [title sizeWithFont:f forWidth:textWidth lineBreakMode:UILineBreakModeTailTruncation];
	[title drawInRect:CGRectMake(padding, ceil((b.size.height - fontSize.height) / 2), textWidth, fontSize.height) withFont:f lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"%@ section index = %i", [super description], section];
}

@end