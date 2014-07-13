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

#import "LILoadImagesOperation.h"

// Keys in the userInfo of NSNotification object
NSString* const LILoadImageOperationUserDataError = @"error";
NSString* const LILoadImageOperationUserDataFileInfo = @"fileInfo";

// Keys in the fileInfo dictionary
NSString* const LILoadImageOperationFileInfoNameKey = @"name";
NSString* const LILoadImageOperationFileInfoPathKey = @"path";
NSString* const LILoadImageOperationFileInfoModifiedDateKey = @"modifiedDate";
NSString* const LILoadImageOperationFileInfoSizeKey = @"size";

// LILoadImagesOperation class
@implementation LILoadImagesOperation

@synthesize _rootURL;
@synthesize _userData;

@synthesize _catchedExInMainTask;

#pragma mark Initializer(s)
+ ( id ) opetationWith: ( NSURL* )_URL
    {
    return [ [ [ [ self class ] alloc ] initWithURL: _URL ] autorelease ];
    }

- ( id ) initWithURL: ( NSURL* )_URL
    {
    if ( self = [ super init ] )
        {
        self->_rootURL = _URL;
        self->_userData = [ NSMutableDictionary dictionary ];
        }

    return self;
    }

#pragma mark Misc
- ( BOOL ) isImageFile: ( NSURL* )_FileForTesting
    {
    BOOL isImageFile = NO;
    NSString* UTLString = nil;
    NSError* error = nil;

    BOOL res = [ _FileForTesting getResourceValue: &UTLString
                                           forKey: NSURLTypeIdentifierKey
                                            error: &error ];
    if ( res && UTLString )
        isImageFile = UTTypeConformsTo( ( __bridge CFStringRef )UTLString, kUTTypeImage );
    else
        self._userData[ LILoadImageOperationUserDataError ] = error;

    return isImageFile;
    }

#pragma mark Overrides for main task
- ( void ) main
    {
    
    }

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