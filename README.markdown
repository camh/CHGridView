#CHGridView

![A screenshot of CHGridView](http://cameron.io/files/CHGridView-sizedToGrid.png) ![A second screenshot of CHGridView](http://cameron.io/files/CHGridView-centered.png)

(Above is two screenshots of CHGridView, one with iPhone Photos-style layout, and another with iPhoto-style layout. CHImageTileView is used for quick image display.)

###About:

I want this to be the last grid view I make. Right now, it's basically a UITableView clone with tiles instead of cells, but in the future I want it to be customizable and flexible enough to reproduce paged icon views, handle un-scrollable grids, display 2000 images, show iPad-like photo stacks with pinch-to-open, and anything else that can be represented with a grid.

CHGridView is modeled after UITableView. You initialize CHGridView, set a delegate and data source, then give it tiles. It's designed to be as easy to use as UITableView.

###Description of classes:

- CHGridView: UIScrollView subclass that handles loading and display of tiles and section titles.
- CHTileView: UIView subclass to draw content, indented to be subclassed for specific use.
- CHImageTileView: CHTileView subclass to easily display images with subtle border, similar to Apple's Photos application.
- CHSectionTitleView: UIView subclass to display section names, can be subclassed and used for custom section titles.
- CHGridLayout: Computes layout and caches it in a big array, makes it easy for CHGridView to only display visible tiles and section titles.
- CHGridLayoutTile: A simple object that stores indexPath and rect for a tile.
- CHGridLayoutSection: Simple object to store section index and its Y co-ordinate position.

###Usage:

[Download a sample view controller class](http://cameron.io/files/CHGridViewController.zip)

Exactly like UITableView. Just implement the two required data source methods: `numberOfTilesInSection` and `tileForIndexPath`. CHGridView assumes there is at least one section. The method `tileForIndexPath` works very much like UITableView; CHGridView reuses tiles just like UITableView reuses cells. Call `dequeueReusableTileWithIdentifier` to get a reusable tile, if it's `nil`, `init` and `autorelease` a new tile and return it.

There's two basic styles to use in GHGridView, one that resembles the iPhone Photos application, and one that mimics iPhoto and the iPad photo grid. The property that controls it is called `dynamicallyResizeTilesToFillSpace`. Set it to `YES` for the iPhone Photos app style.

Row height, tiles per line, padding, section title height and shadow are all properties of CHGridView. These are not meant to change often like the data source and delegate methods. However, if you do change them, make sure to call `reloadData` to recalculate the layout.

Shadows are drawn in Core Graphics and add to your padding. Adjust both until a desirable result is achieved. You can set shadows for a CHTileView directly, but don't; set shadow properties in CHGridView and they will be applied to all tiles.

Orientation changes and resizing are supported. Section titles and tiles are set to the correct autoresizing mask, but you should call `reloadData` after you resize CHGridView for optimal re-layout. You'll need to set CHGridView properties and `reloadData` as needed in your view controller's re-orientation methods.

If you disable scrolling with `setScrollingEnabled`, you can probably use this as a un-scrollable grid view, but I haven't tested it.

###Behind the scenes:

- CHGridView only loads visible tiles and section titles, plus two rows above and beneath. On the iPhone there's only about 30 to 60 tiles loaded at a time.
- CHTileView shadows are not transparent, they are rendered onto the same background color as CHGridView. It's possible to change it if you long for the scrolling performance of Android or WebOS.
- CHImageTileView supports scaling images up/down to fit its frame (and preserves aspect ratio) but it's not fast enough to use. The property is called `scalesImageToHeight` and you should never use it.
- Section titles are only transparent when they need to be, otherwise they are opaque. If you subclass CHSectionTitleView, you'll need to check [self isOpaque] to deal with transparency on your own.

###Roadmap (roughly in order):

- Match speed and performance found in iPhone's Photos app grid view
- More UITableView cloning, like scrolling to a tile at a specific indexPath
- Tile labels
- Flexible per-line setting (maybe a range?)
- Horizontal scrolling and paging support
- Add/remove tile animation
- Multiple selection support
- Nice re-ordering

###Performance:

I tested CHGridView informally with a test application on both my iPhones. For my data source, I used 31 images to populate 1,984 tiles separated with 64 sections. They were exported from iPhoto as PNGs with a maximum width of 160 pixels. The images were drawn centered in CHImageTileView. Scrolling performance is not as good as Apple's Photos grid view, especially on my original iPhone.

- Original iPhone: average 10 - 25 fps.
- iPhone 3G3: average 30 - 50 fps.

Admittedly, performance could be better. I'm not an incredibly experienced programmer, so I'm not privy to a lot of formal programming knowledge. If you see something that could be better, send an email to [me@cameron.io](mailto:me@cameron.io).
