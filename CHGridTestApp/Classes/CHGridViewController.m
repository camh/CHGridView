//
//  CHGridViewController.m
//
//  RELEASED UNDER THE MIT LICENSE
//
//  Created by Cameron Kenly Hunt on 2/22/10.
//  Copyright 2010 Cameron Kenley Hunt All rights reserved.
//  http://cameron.io/project/chgridview
//

#import "CHGridViewController.h"
#import "CHImageTileView.h"

@implementation CHGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        if(myGridView == nil){
			myGridView = [[CHGridView alloc] initWithFrame:CGRectZero];
		}
		if(images == nil){
			images = [[NSMutableArray alloc] init];
		}
    }
    return self;
}

- (void)dealloc {
	[images release];
	[myGridView release];
    [super dealloc];
}

#pragma mark view controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	int i;
	for(i = 0; i < 294; i ++){
		[images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg",i + 1]]];
	}
	
	// set properties of myGridView
	
	[myGridView setDataSource:self];
	[myGridView setDelegate:self];
	
	[myGridView setPadding:CGSizeMake(4.0, 4.0)];
	[myGridView setRowHeight:64.0];
	[myGridView setPerLine:4];
	[myGridView setCenterTilesInGrid:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	//change the perLine setting and reload while orientation changes
	
	if(interfaceOrientation == UIInterfaceOrientationPortrait||
	   interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		[myGridView setPerLine:3];
	}
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation ==UIInterfaceOrientationLandscapeRight){
		[myGridView setPerLine:4];
	}
	[myGridView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[myGridView setFrame:[[self view] bounds]];
	[myGridView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
	[[self view] addSubview:myGridView];
	
	[myGridView reloadData];
}

#pragma mark grid view datasource

- (int)numberOfSectionsInGridView:(CHGridView *)gridView{
	return 7;
}

- (int)numberOfTilesInSection:(int)section GridView:(CHGridView *)gridView{
	return 294;
}

- (CHTileView *)tileForIndexPath:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView{
	static NSString *TileIndentifier = @"Tile";
	
	CHImageTileView *tile = (CHImageTileView *)[gridView dequeueReusableTileWithIdentifier:TileIndentifier];
	
	if(tile == nil)
		tile = [[[CHImageTileView alloc] initWithFrame:CGRectZero reuseIdentifier:TileIndentifier] autorelease];
	
	[tile setImage:[images objectAtIndex:indexPath.tileIndex]];
	
	return tile;
}

#pragma mark grid view delegate

- (NSString *)titleForHeaderOfSection:(int)section inGridView:(CHGridView *)gridView{
	return [NSString stringWithFormat:@"Section %i", section + 1];
}

- (void)selectedTileAtIndexPath:(CHGridIndexPath)indexPath inGridView:(CHGridView *)gridView{
	//deselect after 0.1s so if a user taps quickly, it'll still show it
	[myGridView performSelector:@selector(deselectSelectedTile) withObject:nil afterDelay:0.1];
}

@end
