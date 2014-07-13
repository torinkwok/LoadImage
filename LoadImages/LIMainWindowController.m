///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "LIMainWindowController.h"
#import "LIGetPathsOperation.h"
#import "LILoadImagesOperation.h"

// Announo
@interface LIMainWindowController ()
    {
    NSMutableArray* _tableDataSource;   // The data source for the table
    NSTimer* _timer;               // Update timer for progress indicator
    NSMutableArray* _imagesFoundStr; // Indocates number os images found (NSTextField is bound to this value)
    NSInteger scanCount;
    }

@property ( retain ) NSMutableArray* _tableDataSource;
@property ( retain ) NSTimer* _timer;
@property ( retain ) NSMutableArray* _imagesFoundStr;
@property ( assign ) NSInteger _scanCount;

@end // LIMainWindowController + LIMainWindowController

#pragma mark -

@interface LIMainWindowController ( LIPartForTableViewDataSource )
- ( NSInteger ) numberOfRowsInTableView: ( NSTableView* )_TableView;
- ( id ) tableView: ( NSTableView* )_Table objectValueForTableColumn: ( NSTableColumn* )_Column row: ( NSInteger )_Row;
@end // LIMainWindowController + LIPartForDataSource

#pragma mark -

@interface LIMainWindowController ( LIPartForTableViewDelegate )
- ( void ) tableView: ( NSTableView* )_TableView didClickTableColumn: ( NSTableColumn* )_Column;
@end // LIMainWindowController + LIPartForTableViewDelegate

#pragma mark -

// LIMainWindowController class
@implementation LIMainWindowController

@synthesize _tableView;

@synthesize _startButton;
@synthesize _stopButton;
@synthesize _progressIndicator;

@synthesize _operationQueue; // Queue of NSOperations ( 1 for parsing file system, 2+ for loading image files

@synthesize _tableDataSource;
@synthesize _timer;
@synthesize _imagesFoundStr;
@synthesize _scanCount;

#pragma mark -
#pragma mark Conforms <NSNibAwaking> protocol
- ( void ) awakeFromNib
    {
    // Register for the notification when an image file has been loaded by the NSOperation: LILoadImagesOperation
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( anyThread_handleLoadedImage: )
                                                    name: LILoadImageOperationLoadImageDidFinish
                                                  object: nil ];
    }

- ( void ) anyThread_handleLoadedImage: ( NSNotification* )_Notif
    {
    [ self performSelectorOnMainThread: @selector( mainThread_handleLoadedImage: )
                            withObject: _Notif
                         waitUntilDone: NO ];
    }

- ( void ) mainThread_handleLoadedImage: ( NSNotification* )_Notif
    {
    NSDictionary* imageInfo = [ _Notif userInfo ];

    [ self._tableDataSource addObject: imageInfo ];
    [ self._tableView reloadData ];
    }

#pragma mark -
#pragma mark Initializers
+ ( id ) mainWindowController
    {
    return [ [ [ [ self class ] alloc ] init ] autorelease ];
    }

- ( id ) init
    {
    if ( self = [ super initWithWindowNibName: @"LIMainWindow" ] )
        {
        self._operationQueue = [ [ [ NSOperationQueue alloc ] init ] autorelease ];
        self._tableDataSource = [ NSMutableArray array ];
        }

    return self;
    }

#pragma mark -
#pragma mark IBActions
/* Trigger when user click "Load Images..." button */
- ( IBAction ) startAction: ( id )_Sender
    {
    NSOpenPanel* openPanel = [ NSOpenPanel openPanel ];

    [ openPanel setCanChooseDirectories: YES ];
    [ openPanel setCanChooseFiles: NO ];
    [ openPanel setMessage: NSLocalizedString( @"Choose a directory, which contains a large number of images.", nil ) ];
    [ openPanel setPrompt: @"Choose" ];

    [ openPanel beginSheetModalForWindow: [ self window ]
                       completionHandler:
        ^( NSInteger _Result )
            {
            if ( _Result == NSFileHandlingPanelOKButton )
                {
                /* Because of the extra constraint in open panel, ( [ openPanel setCanChooseFiles: NO ] )
                 * self._url would never be a file name, it's always a dir name. */
                NSURL* dirURL = [ openPanel URL ];

                [ self._tableDataSource removeAllObjects ];
                [ self._tableView reloadData ];

                LIGetPathsOperation* getPathsOperation = [ LIGetPathsOperation opetationWith: dirURL ];
                [ self._operationQueue addOperation: getPathsOperation ];
                }
            } ];
    }

- ( IBAction ) stopAction: ( id )_Sender
    {

    }

@end // LIMainWindowController

#pragma mark -

@implementation LIMainWindowController ( LIPartForTableViewDataSource )

- ( NSInteger ) numberOfRowsInTableView: ( NSTableView* )_TableView
    {
    return [ [ self _tableDataSource ] count ];
    }

- ( id ) tableView: ( NSTableView* )_Table objectValueForTableColumn: ( NSTableColumn* )_Column row: ( NSInteger )_Row
    {
    id objectValue = nil;

    if ( self._tableDataSource.count > 0 )
        {
        NSDictionary* imageInfo = [ self _tableDataSource ][ _Row ];

        objectValue = [ imageInfo objectForKey: [ _Column identifier ] ];
        }

    return objectValue;
    }

@end // LIMainWindowController + LIPartForDataSource

#pragma mark -

@implementation LIMainWindowController ( LIPartForTableViewDelegate )

- ( void ) tableView: ( NSTableView* )_TableView didClickTableColumn: ( NSTableColumn* )_Column
    {
    NSArray* columns = [ _TableView tableColumns ];

    [ columns enumerateObjectsUsingBlock:
        ^( NSTableColumn* _TableColumn, NSUInteger _Index, BOOL* _Stop )
            {
            if ( _TableColumn != _Column )
                {
                [ _TableView setIndicatorImage: nil inTableColumn: _TableColumn ];
                }
            } ];

    NSImage* currentIndicatorImage = [ _TableView indicatorImageInTableColumn: _Column ];

    NSString* ascendingSortIndicatorName = @"NSAscendingSortIndicator";
    NSString* descendingSortIndicatorName = @"NSDescendingSortIndicator";

    NSImage* ascendingSortIndicatorImage = [ NSImage imageNamed: ascendingSortIndicatorName ];
    NSImage* descendingSortIndicatorImage = [ NSImage imageNamed: descendingSortIndicatorName ];

    if ( !currentIndicatorImage )
        [ _TableView setIndicatorImage: ascendingSortIndicatorImage inTableColumn: _Column ];

    else if ( [ [ currentIndicatorImage name ] isEqualToString: ascendingSortIndicatorName ] )
        [ _TableView setIndicatorImage: descendingSortIndicatorImage inTableColumn: _Column ];

    else if ( [ [ currentIndicatorImage name ] isEqualToString: descendingSortIndicatorName ] )
        [ _TableView setIndicatorImage: ascendingSortIndicatorImage inTableColumn: _Column ];
    }

@end // LIMainWindowController + LIPartForTableViewDelegate

/////////////////////////////////////////////////////////////////////////////

/****************************************************************************
 **                                                                        **
 **      _________                                      _______            **
 **     |___   ___|                                   / ______ \           **
 **         | |     _______   _______   _______      | /      |_|          **
 **         | |    ||     || ||     || ||     ||     | |    _ __           **
 **         | |    ||     || ||     || ||     ||     | |   |__  \          **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _       **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|      **
 **                                           ||                           **
 **                                    ||_____||                           **
 **                                                                        **
 ***************************************************************************/
///:~