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
NSString extern* const LILoadImageOperationUserDataError;
NSString extern* const LILoadImageOperationUserDataFileInfo;

// Keys in the fileInfo dictionary
NSString extern* const LILoadImageOperationFileInfoNameKey;
NSString extern* const LILoadImageOperationFileInfoPathKey;
NSString extern* const LILoadImageOperationFileInfoModifiedDateKey;
NSString extern* const LILoadImageOperationFileInfoSizeKey;

// Notification name
NSString extern* const LILoadImageOperationLoadImageWillFinish;
NSString extern* const LILoadImageOperationLoadImageDidFinish;

// LILoadImagesOperation class
@interface LILoadImagesOperation : NSOperation

@property ( copy ) NSArray* _rootURLs;

@property ( retain ) NSMutableArray* _catchedExInMainTask;

#pragma mark Initializer(s)
+ ( id ) operationWithURL: ( NSURL* )_URL;
+ ( id ) operationWithURLs: ( NSArray* )_URLs;
- ( id ) initWithURL: ( NSURL* )_URL;
- ( id ) initWithURLs: ( NSArray* )_URLs;

#pragma mark Misc
- ( BOOL ) isImageFile: ( NSURL* )_FileForTesting;

#pragma mark Overrides for main task
- ( void ) main;

@end // LILoadImagesOperation

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