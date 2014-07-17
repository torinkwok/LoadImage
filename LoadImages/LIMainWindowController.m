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

// Keys in the userInfo of NSNotification object
NSString* const LILoadImageBlockUserDataError = @"error";
NSString* const LILoadImageBlockUserDataFileInfo = @"fileInfo";

// Keys in the fileInfo dictionary
NSString* const LILoadImageBlockFileInfoNameKey = @"name";
NSString* const LILoadImageBlockFileInfoPathKey = @"path";
NSString* const LILoadImageBlockFileInfoModifiedDateKey = @"modifiedDate";
NSString* const LILoadImageBlockFileInfoSizeKey = @"size";

// Notification name
NSString* const LILoadImageBlockLoadImageWillFinish = @"load image will finish";
NSString* const LILoadImageBlockLoadImageDidFinish = @"load image did finish";

BOOL isImageFile( NSURL* );
void loadImagesFunc( void* );

void getPathsFunc( void* _Data )
    {
    NSURL* url = ( NSURL* )_Data;

    NSMutableArray* cachedPaths = [ NSMutableArray array ];
    NSFileManager* fileManager = [ NSFileManager defaultManager ];

    /* 1. Ignores hidden files
     * 2. Ignores package descendents */
    NSDirectoryEnumerator* dirEnumor = [ fileManager enumeratorAtURL: url
                                          includingPropertiesForKeys: nil
                                                             options: NSDirectoryEnumerationSkipsHiddenFiles
                                                                        | NSDirectoryEnumerationSkipsPackageDescendants
                                                        errorHandler: nil ];
    NSInteger cacheCount = 10;
    for ( NSURL* url in dirEnumor )
        {
        if ( cacheCount-- > 0 )
            [ cachedPaths addObject: url ];
        else
            {
            dispatch_async_f( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 )
                            , [ cachedPaths copy ]
                            , loadImagesFunc
                            );

            cacheCount = 10;

            [ cachedPaths removeAllObjects ];
            }
        }
    }

void loadImagesFunc( void* _Data )
    {
    NSArray* rootURLs = ( NSArray* )_Data;

    [ rootURLs enumerateObjectsUsingBlock:
        ^( NSURL* _URL, NSUInteger _Index, BOOL* _Stop )
            {
            if ( isImageFile( _URL ) )
                {
                // Post a notification before loading the image
                [ [ NSNotificationCenter defaultCenter ] postNotificationName: LILoadImageBlockLoadImageWillFinish
                                                                       object: nil
                                                                     userInfo: nil ];

                NSURL* imageURL = _URL;

                NSString* iamgeName = [ [ imageURL URLByDeletingPathExtension ] lastPathComponent ];
                NSString* imagePath = [ imageURL absoluteString ];

                NSDate* modifiedDate = nil;
                [ imageURL getResourceValue: &modifiedDate forKey: NSURLContentModificationDateKey error: nil ];

                NSNumber* imageSize = @0;
                [ imageURL getResourceValue: &imageSize forKey: NSURLFileSizeKey error: nil ];

                // The entry in userInfo will be added to the data source for table view
                NSDictionary* userInfo = @{ LILoadImageBlockFileInfoNameKey : iamgeName
                                          , LILoadImageBlockFileInfoPathKey : imagePath
                                          , LILoadImageBlockFileInfoModifiedDateKey : modifiedDate
                                          , LILoadImageBlockFileInfoSizeKey : [ NSNumber numberWithFloat: imageSize.floatValue / 1024 ]
                                          };

                // Post a notification if the image has been loaded successfully
                [ [ NSNotificationCenter defaultCenter ] postNotificationName: LILoadImageBlockLoadImageDidFinish
                                                                       object: nil
                                                                     userInfo: userInfo ];
                }
            } ];
    }

BOOL isImageFile( NSURL* _FileForTesting )
    {
    BOOL isImageFile = NO;
    NSString* UTLString = nil;
    NSError* error = nil;

    BOOL res = [ _FileForTesting getResourceValue: &UTLString
                                           forKey: NSURLTypeIdentifierKey
                                            error: &error ];
    if ( res && UTLString )
        isImageFile = UTTypeConformsTo( ( __bridge CFStringRef )UTLString, kUTTypeImage );

    return isImageFile;
    }

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
- ( IBAction ) tableViewDoubleClickAction: ( id )_Sender;
- ( void ) tableView: ( NSTableView* )_TableView didClickTableColumn: ( NSTableColumn* )_Column;
@end // LIMainWindowController + LIPartForTableViewDelegate

#pragma mark -

// LIMainWindowController class
@implementation LIMainWindowController

#pragma mark Synthesized Properties
@synthesize _tableView;

@synthesize _startButton;
@synthesize _stopButton;
@synthesize _progressIndicator;

@synthesize _operationQueue; // Queue of NSOperations ( 1 for parsing file system, 2+ for loading image files
    @synthesize _getPathsOperation;

@synthesize _tableDataSource;
@synthesize _timer;
@synthesize _imagesFoundStr;
@synthesize _scanCount;

#pragma mark Conforms <NSNibAwaking> protocol
- ( void ) awakeFromNib
    {
    // Register for the notification when an image file has been loaded by the NSOperation: LILoadImagesOperation
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( anyThread_handleLoadedImage: )
                                                    name: LILoadImageBlockLoadImageDidFinish
                                                  object: nil ];

    [ self._tableView setTarget: self ];
    [ self._tableView setDoubleAction: @selector( tableViewDoubleClickAction: ) ];
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

//                self._getPathsOperation = [ LIGetPathsOperation operationWithURL: dirURL ];
//                [ self._operationQueue addOperations: @[ self._getPathsOperation ] waitUntilFinished: NO ];

                dispatch_async_f( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 )
                                , dirURL
                                , getPathsFunc
                                );
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

- ( IBAction ) tableViewDoubleClickAction: ( id )_Sender
    {
    NSTableView* tableView = ( NSTableView* )_Sender;

    NSInteger row = [ tableView selectedRow ];
    if ( row > -1 )
        {
        NSString* pathOfSelectedImage = [ self._tableDataSource[ row ] objectForKey: LILoadImageBlockFileInfoPathKey ];
        NSURL* imageURL = [ NSURL URLWithString: pathOfSelectedImage ];

        // FIXME:
        NSLog( @"Path: %@", pathOfSelectedImage );
        NSLog( @"URL: %@", imageURL );

        [ [ NSWorkspace sharedWorkspace ] openURL: [ NSURL URLWithString: pathOfSelectedImage ] ];
        }
    }

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

#pragma mark The New Journey for GCD
- ( IBAction ) printTheDefaultQueue: ( id )_Sender
    {
    dispatch_queue_t globalDefaultQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    NSLog( @"Global Dispatch Queue with Default Priority: %@ #%@", globalDefaultQueue, NSStringFromSelector( _cmd ) );

    dispatch_queue_t customDefaultQueue = dispatch_queue_create( "individual.TongG.LoadImages.", DISPATCH_QUEUE_CONCURRENT );
    NSLog( @"Custom Dispatch Queue with Default Priority: %p", customDefaultQueue );
    }

void ( ^fuckBlock )() =
    ^( void )
        {
        sleep( 10 );
        NSLog( @"FuckBlock!" );
        };

void ( ^anotherFuckBlock )() =
    ^( void )
        {
        sleep( 10 );
        NSLog( @"FuckBlock!" );
        };

void fuckFunc( void* _ContextData )
    {
    sleep( 10 );
    NSLog( @"FuckFunc!" );
    }

- ( IBAction ) testingForFinalizer: ( id )_Sender
    {
    dispatch_queue_t fuckDispatchQueue = dispatch_queue_create( "individual.TongG.fuckDispatchQueue", DISPATCH_QUEUE_CONCURRENT );

    NSDate* fuckDate = [ [ NSDate alloc ] initWithTimeIntervalSinceNow: 20 ];
    dispatch_set_context( fuckDispatchQueue, fuckDate );
    dispatch_set_finalizer_f( fuckDispatchQueue, fuckFinalizer );

    dispatch_async( fuckDispatchQueue, fuckBlock );
    dispatch_async( fuckDispatchQueue, anotherFuckBlock );
//    dispatch_async_f( fuckDispatchQueue, [ NSDate distantFuture ], fuckFunc );

    dispatch_release( fuckDispatchQueue );
    }

void fuckFinalizer( void* _Context )
    {
    NSLog( @"#%s\n Context: %@", __func__, _Context );

    [ ( NSDate* )_Context release ];
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