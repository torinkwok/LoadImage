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

// LIMainWindowController + LIMainUserInterface
@interface LIMainWindowController ( LIMainUserInterface )

@property ( copy ) NSMutableArray* _tableRecords;   // The data source for the table

@property ( retain ) NSTimer* _timer;               // Update timer for progress indicator

@property ( copy ) NSMutableArray* _imagesFoundStr; // Indocates number os images found (NSTextField is bound to this value)

@property ( assign )  NSInteger scanCount;

@end // LIMainWindowController + LIMainWindowController

#pragma mark -

// LIMainWindowController class
@implementation LIMainWindowController

@synthesize _tableView;

@synthesize _startButton;
@synthesize _stopButton;
@synthesize _progressIndicator;

@synthesize _operationQueue; // Queue of NSOperations ( 1 for parsing file system, 2+ for loading image files

#pragma mark -
#pragma mark Conforms <NSNibAwaking> protocol
- ( void ) awakeFromNib
    {
    // Register for the notification then an
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
        self._operationQueue = [ [ [ NSOperationQueue alloc ] init ] autorelease ];

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

                LIGetPathsOperation* getPathsOperation = [ LIGetPathsOperation opetationWith: dirURL ];
                [ self._operationQueue addOperation: getPathsOperation ];
                }
            } ];
    }

- ( IBAction ) stopAction: ( id )_Sender
    {

    }

@end // LIMainWindowController

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