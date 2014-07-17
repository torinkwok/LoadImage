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

#import <Cocoa/Cocoa.h>

// Keys in the userInfo of NSNotification object
NSString extern* const LILoadImageBlockUserDataError;
NSString extern* const LILoadImageBlockUserDataFileInfo;

// Keys in the fileInfo dictionary
NSString extern* const LILoadImageBlockFileInfoNameKey;
NSString extern* const LILoadImageBlockFileInfoPathKey;
NSString extern* const LILoadImageBlockFileInfoModifiedDateKey;
NSString extern* const LILoadImageBlockFileInfoSizeKey;

// Notification name
NSString extern* const LILoadImageBlockLoadImageWillFinish;
NSString extern* const LILoadImageBlockLoadImageDidFinish;

@class LIGetPathsOperation;

// LIMainWindowController class
@interface LIMainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property ( assign ) IBOutlet NSTableView* _tableView;  // The table holding the image paths

@property ( assign ) IBOutlet NSButton* _startButton;
@property ( assign ) IBOutlet NSButton* _stopButton;

@property ( assign ) IBOutlet NSProgressIndicator* _progressIndicator;

@property ( retain ) NSOperationQueue* _operationQueue;
    @property ( retain ) LIGetPathsOperation* _getPathsOperation;

@property ( retain ) dispatch_queue_t _customDispatchQueue;

+ ( id ) mainWindowController;

#pragma mark -
#pragma mark IBActions
- ( IBAction ) startAction: ( id )_Sender;
- ( IBAction ) stopAction: ( id )_Sender;

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